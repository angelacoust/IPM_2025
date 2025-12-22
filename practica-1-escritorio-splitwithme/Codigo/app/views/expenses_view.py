import gi
gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, Gdk, GLib
from datetime import datetime
from app.i18n import t
from app.presenters.expenses_presenter import ExpensesPresenter
import threading


# vista principal de gastos
class ExpensesView(Gtk.Box):
    # inicializamos vista de gastos
    def __init__(self, api_client, parent_window):
        super().__init__(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10,
            margin_top=12,
            margin_bottom=12,
            margin_start=12,
            margin_end=12,
        )
        # inicializamos presenter asociado y datos
        self.presenter = ExpensesPresenter(self, api_client)
        self.parent_window = parent_window  # referencia a mainwindow
        self._expenses_data = []
        self.selected_row_widget = None
        self.selected_id = None

        # Barra superior
        top_bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        top_bar.add_css_class("top-bar")

        # campo de busqueda
        self.search_entry = Gtk.Entry(placeholder_text=t("search_expense_placeholder"))
        self.search_entry.set_hexpand(True)

        # Botones superiores
        btn_search = Gtk.Button(label=t("search"))  # buscar gasto
        btn_search.add_css_class("search-button")
        btn_search.connect("clicked", self.on_search_clicked)

        btn_reload = Gtk.Button(label=t("reload"))  # recargar lista de gastos
        btn_reload.add_css_class("reload-button")
        btn_reload.connect("clicked", self.on_reload_clicked)

        btn_create = Gtk.Button(label=t("create_expense"))  # crear nuevo gasto
        btn_create.add_css_class("create-expense-button")
        btn_create.connect("clicked", self.on_add_clicked)

        btn_edit = Gtk.Button(label=t("edit_expense"))  # editar gasto seleccionado
        btn_edit.add_css_class("edit-expense-button")
        btn_edit.connect("clicked", self.on_edit_clicked)

        btn_delete = Gtk.Button(label=t("delete_expense"))  # eliminar gasto seleccionado
        btn_delete.add_css_class("delete-expense-button")
        btn_delete.connect("clicked", self.on_delete_clicked)

        # lista de botones de acción para poder deshabilitarlos en show_loading()
        self._action_buttons = [btn_search, btn_reload, btn_create, btn_edit, btn_delete]

        # Spinner de carga
        self.spinner = Gtk.Spinner()
        self.spinner.set_halign(Gtk.Align.CENTER)
        self.spinner.set_valign(Gtk.Align.CENTER)
        self.spinner.hide()

        # añadir widgets a la barra superior
        top_bar.append(self.search_entry)
        top_bar.append(btn_search)
        top_bar.append(btn_reload)
        top_bar.append(btn_create)
        top_bar.append(btn_edit)
        top_bar.append(btn_delete)
        top_bar.append(self.spinner)

        # Grid de gastos
        self.grid = Gtk.Grid(column_spacing=25, row_spacing=6)
        self.grid.add_css_class("expenses-grid")

        scrolled = Gtk.ScrolledWindow(hexpand=True, vexpand=True)  # area desplazante
        scrolled.set_child(self.grid)

        # Barra de estado inferior
        self.status = Gtk.Label(xalign=0)
        self.status.add_css_class("status-label")

        # añadir barra, grid y estado
        self.append(top_bar)
        self.append(scrolled)
        self.append(self.status)

    # ----------------------------------------------------------------------
    # soporte para concurrencia (spinner + bloqueo de botones)
    # ----------------------------------------------------------------------

    def show_loading(self):
        self.spinner.show()
        self.spinner.start()
        for btn in self._action_buttons:
            btn.set_sensitive(False)

    def hide_loading(self):
        self.spinner.stop()
        self.spinner.hide()
        for btn in self._action_buttons:
            btn.set_sensitive(True)

    # ----------------------------------------------------------------------
    # dialogo de error
    # ----------------------------------------------------------------------

    
    
    #dialogo de error
    def show_error_dialog(self, message):
        raw = str(message)

        # Si el backend está caído / no hay conexión, el texto contiene esto
        if (
            "HTTPConnectionPool" in raw
            or "Failed to establish a new connection" in raw
            or "Connection refused" in raw
            or "Max retries exceeded with url" in raw
        ):
            raw = t("server_error_offline")

        d = Gtk.MessageDialog(
            transient_for=self.get_root(),
            modal=True,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text=f"{t('error_prefix')}{raw}",
        )
        d.connect("response", lambda dd, r: dd.destroy())
        d.present()



    # ----------------------------------------------------------------------
    # acciones barra superior
    # ----------------------------------------------------------------------

    def on_reload_clicked(self, _btn):
        # al recargar reseteo filtro
        self.search_entry.set_text("")
        # load_expenses ya usa safe_call_threaded en el presenter,
        # que llamará a show_loading/hide_loading de esta vista.
        self.presenter.load_expenses("")

    def on_search_clicked(self, _btn):
        query = self.search_entry.get_text().strip()
        self.presenter.load_expenses(query if query else None)

    def on_add_clicked(self, _btn):
        self.show_expense_dialog(t("create_expense"))

    def on_edit_clicked(self, _btn):
        if not self.selected_id:
            self.show_error_dialog(t("select_expense_first"))
            return
        try:
            expense = next(
                (e for e in self._expenses_data if e.get("id") == self.selected_id),
                None,
            )
            if not expense:
                self.show_error_dialog(t("expense_not_found"))
                return

            self.show_expense_dialog(t("edit_expense"), expense)
        except Exception as e:
            self.show_error_dialog(f"{t('load_expense_error_prefix')}{e}")

    def on_delete_clicked(self, _btn):
        if not self.selected_id:
            self.show_error_dialog(t("select_expense_first"))
            return

        expense_id = self.selected_id

        def worker():
            try:
                # Operaciones lentas en hilo: delete + recarga de lista
                self.presenter.api.delete_expense(expense_id)
                expenses = self.presenter.api.list_expenses()

                def update_ui():
                    # limpiar selección
                    self.selected_id = None
                    self.selected_row_widget = None
                    # refrescar tabla
                    self.show_expenses(expenses)
                    self.show_error(
                        f"{t('expense_deleted_prefix')}{expense_id}"
                    )
                    self.hide_loading()
                    return False

                GLib.idle_add(update_ui)

            except Exception as e:
                def show_err():
                    self.hide_loading()
                    self.show_error_dialog(f"{t('delete_error_prefix')}{e}")
                    return False

                GLib.idle_add(show_err)

        self.show_loading()
        threading.Thread(target=worker, daemon=True).start()

    def on_expense_selected(self, expense_id):
        self.parent_window.show_expense_detail(expense_id)

    # ----------------------------------------------------------------------
    # mostrar tabla de gastos
    # ----------------------------------------------------------------------

    def show_expenses(self, expenses):
        self._expenses_data = expenses or []

        # Vaciar grid
        for child in list(self.grid):
            self.grid.remove(child)

        # Cabeceras
        headers = [
            t("id"),
            t("description"),
            t("date"),
            t("amount"),
            t("credit"),
            t("friends_section"),
            t("actions"),
        ]
        for col, text in enumerate(headers):
            lbl = Gtk.Label(label=text, xalign=0)
            lbl.add_css_class("table-header")
            self.grid.attach(lbl, col, 0, 1, 1)

        # Filas
        for row, e in enumerate(self._expenses_data, start=1):
            row_box = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=25,
            )
            row_box.add_css_class("table-row")

            values = [
                str(e.get("id", "")),
                e.get("description", ""),
                e.get("date", ""),
                f"{e.get('amount', 0):.2f}€",
                f"{e.get('credit_balance', 0):.2f}€",
                str(e.get("num_friends", 0)),
            ]
            for val in values:
                lbl = Gtk.Label(label=val, xalign=0)
                lbl.add_css_class("table-cell")
                row_box.append(lbl)

            # Botón "Ver" detalle
            btn_view = Gtk.Button(label=t("view"))
            btn_view.connect(
                "clicked",
                lambda btn, eid=e.get("id"): self.parent_window.show_expense_detail(eid)
            )
            row_box.append(btn_view)

            # selección de fila (resaltado)
            click = Gtk.GestureClick()
            click.connect("pressed", self.on_row_clicked, e, row_box)
            row_box.add_controller(click)

            self.grid.attach(row_box, 0, row, len(headers), 1)

        # Estado inferior
        self.status.set_text(
            t("num_expenses_count").format(count=len(self._expenses_data))
        )

    # ----------------------------------------------------------------------
    # resaltar fila seleccionada
    # ----------------------------------------------------------------------

    def on_row_clicked(self, _gesture, _n_press, _x, _y, expense, row_widget):
        if self.selected_row_widget:
            self.selected_row_widget.remove_css_class("table-row-selected")
        row_widget.add_css_class("table-row-selected")
        self.selected_row_widget = row_widget
        self.selected_id = expense.get("id")
        self.show_error(
            t("selected_id").format(id=self.selected_id)
        )

    # ----------------------------------------------------------------------
    # Mostrar mensaje de error / estado
    # ----------------------------------------------------------------------

    def show_error(self, message: str):
        self.status.set_text(message)

    # ----------------------------------------------------------------------
    # dialogo crear o editar gasto (CONCURRENTE)
    # ----------------------------------------------------------------------

    def show_expense_dialog(self, title, expense=None):
        dialog = Gtk.Dialog(
            title=title,
            transient_for=self.get_root(),
            modal=True,
        )
        dialog.set_default_size(320, 180)
        box = dialog.get_content_area()

        grid = Gtk.Grid(
            column_spacing=10,
            row_spacing=10,
            margin_top=10,
            margin_bottom=10,
            margin_start=10,
            margin_end=10,
        )
        box.append(grid)

        # campos de entrada y etiquetas
        lbl_desc = Gtk.Label(label=t("field_description_label"))
        entry_desc = Gtk.Entry(text=expense["description"] if expense else "")

        lbl_date = Gtk.Label(label=t("field_date_label"))
        entry_date = Gtk.Entry(text=expense["date"] if expense else "")

        lbl_amount = Gtk.Label(label=t("field_amount_label"))
        entry_amount = Gtk.Entry(text=str(expense["amount"]) if expense else "")

        grid.attach(lbl_desc,   0, 0, 1, 1)
        grid.attach(entry_desc, 1, 0, 1, 1)

        grid.attach(lbl_date,   0, 1, 1, 1)
        grid.attach(entry_date, 1, 1, 1, 1)

        grid.attach(lbl_amount,   0, 2, 1, 1)
        grid.attach(entry_amount, 1, 2, 1, 1)

        dialog.add_button(t("cancel"), Gtk.ResponseType.CANCEL)
        dialog.add_button(t("accept"), Gtk.ResponseType.OK)

        def on_response(dlg, response_id):
            if response_id != Gtk.ResponseType.OK:
                dlg.destroy()
                return

            description = entry_desc.get_text().strip()
            date = entry_date.get_text().strip()
            amount_text = entry_amount.get_text().strip()

            # validación básica
            if not description or not date or not amount_text:
                self.show_error_dialog(t("missing_required_field"))
                return

            try:
                datetime.strptime(date, "%Y-%m-%d")
                float(amount_text.replace(',', '.'))
            except Exception:
                self.show_error_dialog(t("invalid_field"))
                return

            amount = float(amount_text.replace(',', '.'))

            # --------------------------
            # CREAR NUEVO GASTO (HILO)
            # --------------------------
            if expense is None:

                def worker_create():
                    try:
                        new_expense = self.presenter.api.create_expense(
                            description=description,
                            date=date,
                            amount=amount,
                        )
                        expenses = self.presenter.api.list_expenses()

                        def update_ui():
                            self.show_expenses(expenses)
                            self.show_error(
                                f"{t('created_expense_prefix')}{new_expense.get('id', '?')}"
                            )
                            self.hide_loading()
                            return False

                        GLib.idle_add(update_ui)

                    except Exception as e:
                        def show_err():
                            self.hide_loading()
                            self.show_error_dialog(f"{t('creating_expense_prefix')}{e}")
                            return False

                        GLib.idle_add(show_err)

                self.show_loading()
                threading.Thread(target=worker_create, daemon=True).start()

            # --------------------------
            # EDITAR GASTO EXISTENTE (HILO)
            # --------------------------
            else:

                def worker_update():
                    try:
                        # actualizar datos locales
                        expense["description"] = description
                        expense["date"] = date
                        expense["amount"] = amount

                        payload = expense.copy()
                        self.presenter.api.update_expense(expense["id"], payload)
                        expenses = self.presenter.api.list_expenses()

                        def update_ui():
                            self.show_expenses(expenses)
                            self.show_error(
                                f"{t('updated_expense_prefix')}{expense['id']}"
                            )
                            self.hide_loading()
                            return False

                        GLib.idle_add(update_ui)

                    except Exception as e:
                        def show_err():
                            self.hide_loading()
                            self.show_error_dialog(f"{t('updating_expense_prefix')}{e}")
                            return False

                        GLib.idle_add(show_err)

                self.show_loading()
                threading.Thread(target=worker_update, daemon=True).start()

            dlg.destroy()

        dialog.connect("response", on_response)
        dialog.present()


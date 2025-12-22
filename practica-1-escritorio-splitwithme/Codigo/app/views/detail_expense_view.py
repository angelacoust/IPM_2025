
import gi
gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, GLib
from app.i18n import t
from app.presenters.detail_expense_presenter import DetailExpensePresenter
import threading


# vista del detalle de un gasto
class DetailExpenseView(Gtk.Box):

    def __init__(self, api_client, expense_id, on_back):
        super().__init__(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=8,
            margin_top=8,
            margin_bottom=8,
            margin_start=8,
            margin_end=8,
        )

        self.api = api_client
        self.expense_id = expense_id
        self.on_back = on_back
        self.current_friend_ids = []
        self._action_buttons = []

        # Presenter
        self.presenter = DetailExpensePresenter(self, api_client)

        # Barra superior con botón volver + spinner
        header_bar = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=8,
        )

        self.back_btn = Gtk.Button(label=t("back"))
        self.back_btn.connect("clicked", self._handle_back_clicked)
        header_bar.append(self.back_btn)

        self.spinner = Gtk.Spinner()
        self.spinner.set_visible(False)
        header_bar.append(self.spinner)

        self.append(header_bar)

        # Zona central en dos columnas
        main_row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=24,
        )
        self.append(main_row)

        # Columna izquierda: info del gasto
        self.info_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=4,
        )

        self.lbl_id = Gtk.Label(xalign=0)
        self.lbl_desc = Gtk.Label(xalign=0)
        self.lbl_date = Gtk.Label(xalign=0)
        self.lbl_credit_balance = Gtk.Label(xalign=0)
        self.lbl_amount = Gtk.Label(xalign=0)

        for lbl in (
            self.lbl_id,
            self.lbl_desc,
            self.lbl_date,
            self.lbl_credit_balance,
            self.lbl_amount,
        ):
            lbl.set_selectable(False)
            lbl.set_xalign(0.0)

        self.info_box.append(self.lbl_id)
        self.info_box.append(self.lbl_desc)
        self.info_box.append(self.lbl_date)
        self.info_box.append(self.lbl_credit_balance)
        self.info_box.append(self.lbl_amount)

        main_row.append(self.info_box)

        # Columna derecha: tabla de amigos
        right_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=6,
        )
        main_row.append(right_box)

        header_row = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=8,
        )

        lbl_h_id = Gtk.Label(label=t("id"))
        lbl_h_name = Gtk.Label(label=t("name"))
        lbl_h_credit = Gtk.Label(label=t("credit"))
        lbl_h_debit = Gtk.Label(label=t("debit"))
        lbl_h_actions = Gtk.Label(label=t("actions"))

        for h in (lbl_h_id, lbl_h_name, lbl_h_credit, lbl_h_debit, lbl_h_actions):
            h.set_xalign(0.0)

        header_row.append(lbl_h_id)
        header_row.append(lbl_h_name)
        header_row.append(lbl_h_credit)
        header_row.append(lbl_h_debit)
        header_row.append(lbl_h_actions)

        right_box.append(header_row)

        self.friends_rows_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=6,
        )
        right_box.append(self.friends_rows_box)

        # Barra inferior de estado
        self.status_label = Gtk.Label(label="")
        self.status_label.set_xalign(0.0)
        self.append(self.status_label)

        # CARGA INICIAL
        self.presenter.load_expense_detail(self.expense_id)

    # ----------------------------------------------------------------------
    # CONCURRENCIA: spinner + bloqueo de botones
    # ----------------------------------------------------------------------

    def show_loading(self):
        self.spinner.set_visible(True)
        self.spinner.start()
        for btn in self._action_buttons:
            btn.set_sensitive(False)

    def hide_loading(self):
        self.spinner.stop()
        self.spinner.set_visible(False)
        for btn in self._action_buttons:
            btn.set_sensitive(True)

    # ----------------------------------------------------------------------

    def show_error(self, msg: str):
        self.status_label.set_text(msg)

    def show_status(self, msg: str):
        self.status_label.set_text(msg)

    
    def show_error_dialog(self, msg: str):
        raw = str(msg)

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
    # MOSTRAR INFO DEL GASTO
    # ----------------------------------------------------------------------

    def show_expense_detail(self, expense: dict):

        self.expense_id = expense.get("id", self.expense_id)

        desc = expense.get("description", "")
        date = expense.get("date", "")
        amount = expense.get("amount", 0.0)
        credit_balance = expense.get("credit_balance", 0.0)

        self.lbl_id.set_text(f"{t('expense_id')}: {self.expense_id}")
        self.lbl_desc.set_text(desc)
        self.lbl_date.set_text(f"{t('expense_date')}: {date}")
        self.lbl_credit_balance.set_text(f"{t('credit_balance')}: {credit_balance:.2f}€")
        self.lbl_amount.set_text(f"{t('amount_total')}: {amount:.2f}€")

    # ----------------------------------------------------------------------
    # MOSTRAR TABLA DE AMIGOS
    # ----------------------------------------------------------------------

    def show_friends(self, friends: list[dict]):

        self._action_buttons = []

        for child in list(self.friends_rows_box):
            self.friends_rows_box.remove(child)

        for friend in friends:

            fid = friend.get("id")
            name = friend.get("name", "")
            credit = friend.get("credit_balance", friend.get("credit", 0.0))
            debit = friend.get("debit_balance", friend.get("debit", 0.0))

            row = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=8,
            )

            lbl_id = Gtk.Label(label=str(fid))
            lbl_name = Gtk.Label(label=name)
            lbl_credit = Gtk.Label(label=f"{credit:.2f}€")
            lbl_debit = Gtk.Label(label=f"{debit:.2f}€")

            for lbl in (lbl_id, lbl_name, lbl_credit, lbl_debit):
                lbl.set_xalign(0.0)

            row.append(lbl_id)
            row.append(lbl_name)
            row.append(lbl_credit)
            row.append(lbl_debit)

            btn_update = Gtk.Button(label=t("update_credit"))
            btn_update.connect(
                "clicked",
                lambda _b, eid=self.expense_id, frid=fid: self.presenter.update_credit(eid, frid),
            )
            row.append(btn_update)

            btn_delete = Gtk.Button(label=t("delete_expense"))
            btn_delete.connect(
                "clicked",
                lambda _b, eid=self.expense_id, frid=fid: self.presenter.delete_friend(eid, frid),
            )
            row.append(btn_delete)

            self._action_buttons.append(btn_update)
            self._action_buttons.append(btn_delete)

            self.friends_rows_box.append(row)

        btn_add = Gtk.Button(label="+ " + t("add_friend"))
        btn_add.connect(
            "clicked",
            lambda _b, eid=self.expense_id: self.presenter.add_friend(eid),
        )
        self._action_buttons.append(btn_add)

        self.friends_rows_box.append(btn_add)

        self.current_friend_ids = [f.get("id") for f in friends if "id" in f]

    # ----------------------------------------------------------------------
    # DIALOGOS
    # ----------------------------------------------------------------------

    def show_update_credit(self, callback):

        dialog = Gtk.Dialog(
            title=t("update_credit_title"),
            transient_for=self.get_root(),
            modal=True,
        )
        dialog.set_default_size(250, 100)
        box = dialog.get_content_area()

        grid = Gtk.Grid(
            column_spacing=8,
            row_spacing=8,
            margin_top=10,
            margin_bottom=10,
            margin_start=10,
            margin_end=10,
        )
        box.append(grid)

        lbl = Gtk.Label(label=t("new_amount_label"))
        entry = Gtk.Entry()
        entry.set_input_purpose(Gtk.InputPurpose.NUMBER)

        grid.attach(lbl, 0, 0, 1, 1)
        grid.attach(entry, 1, 0, 1, 1)

        dialog.add_button(t("cancel"), Gtk.ResponseType.CANCEL)
        dialog.add_button(t("save"), Gtk.ResponseType.OK)

        def on_response(dlg, response_id):
            result = None
            if response_id == Gtk.ResponseType.OK:
                txt = entry.get_text().strip()
                try:
                    result = {"amount": float(txt)}
                except ValueError:
                    result = None
                    self.show_error(t("invalid_amount"))
            dlg.destroy()
            if callback:
                callback(result)

        dialog.connect("response", on_response)
        dialog.present()

    # ----------------------------------------------------------------------
    # DIALOGO: AÑADIR AMIGO (CONCURRENTE)
    # ----------------------------------------------------------------------

    def show_add_friend(self, callback):

        def worker():
            try:
                all_friends = self.presenter.api.list_friends()
                available = [
                    f for f in all_friends
                    if f.get("id") not in self.current_friend_ids
                ]

                def open_dialog():

                    dialog = Gtk.Dialog(
                        title=t("add_friend_title"),
                        transient_for=self.get_root(),
                        modal=True,
                    )
                    dialog.set_default_size(300, 120)
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

                    lbl_select = Gtk.Label(label=t("select_friend"))
                    combo = Gtk.ComboBoxText()

                    for friend in available:
                        combo.append(str(friend["id"]), friend.get("name", ""))

                    if available:
                        combo.set_active(0)

                    grid.attach(lbl_select, 0, 0, 1, 1)
                    grid.attach(combo, 1, 0, 1, 1)

                    dialog.add_button(t("cancel"), Gtk.ResponseType.CANCEL)
                    dialog.add_button(t("add"), Gtk.ResponseType.OK)

                    def on_response(dlg, response_id):
                        result = None
                        if response_id == Gtk.ResponseType.OK:
                            fid = combo.get_active_id()
                            if fid is not None:
                                result = {"friend_id": int(fid)}
                            else:
                                self.show_error(t("no_friend_selected"))
                        dlg.destroy()
                        if callback:
                            callback(result)

                    dialog.connect("response", on_response)
                    dialog.present()

                    self.hide_loading()
                    return False

                GLib.idle_add(open_dialog)

            except Exception as e:
                def show_err():
                    self.hide_loading()
                    self.show_error_dialog(str(e))
                    return False

                GLib.idle_add(show_err)

        self.show_loading()
        threading.Thread(target=worker, daemon=True).start()

    # ----------------------------------------------------------------------
    # BOTÓN VOLVER
    # ----------------------------------------------------------------------

    def _handle_back_clicked(self, btn):
        if callable(self.on_back):
            try:
                self.on_back(btn)
            except TypeError:
                self.on_back()



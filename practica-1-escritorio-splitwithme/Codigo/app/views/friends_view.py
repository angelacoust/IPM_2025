import gi
gi.require_version("Gtk", "4.0")

from gi.repository import Gtk
from app.i18n import t
from app.presenters.friends_presenter import FriendsPresenter


# vista de amigos sin posibilidad de añadir nuevos
class FriendsView(Gtk.Box):

    def __init__(self, api_client):
        super().__init__(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10,
            margin_top=12,
            margin_bottom=12,
            margin_start=12,
            margin_end=12,
        )

        # inicializamos presenter asociado y datos
        self.presenter = FriendsPresenter(self, api_client)
        self._friends_data = []

        # spinner de carga
        self.spinner = Gtk.Spinner()
        self.spinner.set_halign(Gtk.Align.CENTER)
        self.spinner.set_valign(Gtk.Align.CENTER)
        self.spinner.hide()
        self.append(self.spinner)

        # barra superior con búsqueda
        top_bar = Gtk.Box(spacing=8)
        self.search_entry = Gtk.Entry(
            placeholder_text=t("search_friend_placeholder")
        )
        btn_search = Gtk.Button(label=t("search"))
        btn_search.connect("clicked", self.on_search_clicked)
        btn_reload = Gtk.Button(label=t("reload"))
        btn_reload.connect("clicked", self.on_reload_clicked)
        top_bar.append(self.search_entry)
        top_bar.append(btn_search)
        top_bar.append(btn_reload)
        self.append(top_bar)

        # layout lista + detalle
        main_content = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=20,
        )
        self.append(main_content)

        # lista de amigos (izquierda)
        self.list_box = Gtk.ListBox()
        self.list_box.set_size_request(220, -1)
        self.list_box.connect("row_selected", self.on_row_selected)
        main_content.append(self.list_box)

        # panel de detalle (derecha)
        self.detail_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=10,
        )
        self.detail_box.set_hexpand(True)
        main_content.append(self.detail_box)

        # estado / mensajes
        self.status = Gtk.Label(xalign=0)
        self.append(self.status)

        # carga inicial
        self.show_loading()
        self.presenter.load_friends()

    # ------------------------------------------------------------------
    # callbacks para botones y eventos
    # ------------------------------------------------------------------

    def on_search_clicked(self, _btn):
        query = self.search_entry.get_text().strip()
        self.show_loading()
        self.presenter.load_friends(query if query else None)

    def on_reload_clicked(self, _btn):
        self.search_entry.set_text("")
        self.show_loading()
        self.presenter.load_friends()

    def on_row_selected(self, _listbox, row):
        if not row:
            return
        idx = row.get_index()
        if idx < 0 or idx >= len(self._friends_data):
            return
        friend = self._friends_data[idx]
        self.presenter.select_friend(friend.get("id"))

    # ------------------------------------------------------------------
    # métodos llamados desde el presenter
    # ------------------------------------------------------------------

    def show_friends(self, friends):
        self.hide_loading()
        self._friends_data = friends or []

        # limpiar lista previa
        for row in list(self.list_box):
            self.list_box.remove(row)

        # crear filas
        for f in self._friends_data:
            name = f.get("name", f"{t('friend')} {f.get('id')}")
            username = f.get("username", f"user{f.get('id')}")
            debit = float(f.get("debit_balance", 0) or 0)
            credit = float(f.get("credit_balance", 0) or 0)

            row_box = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=12,
            )
            row_box.add_css_class("friend-row")

            lbl_name = Gtk.Label(label=name, xalign=0)
            lbl_name.add_css_class("friend-name")

            lbl_user = Gtk.Label(label=username, xalign=0)
            lbl_user.add_css_class("friend-username")

            lbl_debit = Gtk.Label(
                label=f"{t('debit')}: {debit:.2f}€",
                xalign=0,
            )
            lbl_debit.add_css_class("debit-label")

            lbl_credit = Gtk.Label(
                label=f"{t('credit')}: {credit:.2f}€",
                xalign=0,
            )
            lbl_credit.add_css_class("credit-label")

            row_box.append(lbl_name)
            row_box.append(lbl_user)
            row_box.append(lbl_debit)
            row_box.append(lbl_credit)

            self.list_box.append(row_box)

        self.list_box.show()
        self.status.set_text(
            t("friends_loaded_count").format(count=len(self._friends_data))
        )

    def show_friend_detail(self, friend):
        # limpiar panel derecho
        for child in list(self.detail_box):
            self.detail_box.remove(child)

        # datos base
        fid = friend.get("id", "")
        name = friend.get("name", str(fid))
        credit_balance = float(friend.get("credit_balance", 0) or 0)
        debit_balance = float(friend.get("debit_balance", 0) or 0)
        net = credit_balance - debit_balance

        lbl_name = Gtk.Label(
            label=f"{t('friend_name')}: {name}",
            xalign=0,
        )
        lbl_id = Gtk.Label(
            label=f"{t('friend_id')}: {fid}",
            xalign=0,
        )
        lbl_credit = Gtk.Label(
            label=f"{t('credit_balance_label')}: {credit_balance:.2f}€",
            xalign=0,
        )
        lbl_debit = Gtk.Label(
            label=f"{t('debit_balance_label')}: {debit_balance:.2f}€",
            xalign=0,
        )
        lbl_net = Gtk.Label(
            label=f"{t('net_balance_label')}: {net:+.2f}€",
            xalign=0,
        )

        lbl_assigned = Gtk.Label(
            label=f"{t('assigned_to')}:",
            xalign=0,
        )

        expenses_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=4,
        )

        for exp in friend.get("expenses", []):
            amount = float(exp.get("amount", 0) or 0)

            exp_name = exp.get("name")
            if not exp_name or str(exp_name).strip() == "":
                exp_name = t("expense_label")

            desc = exp.get("description") or exp.get("name") or t("expense_label")
            lbl_exp = Gtk.Label(
                label=f"{desc} — {amount:.2f}€",
                xalign=0,
            )
            expenses_box.append(lbl_exp)

        # montar en panel derecho
        self.detail_box.append(lbl_name)
        self.detail_box.append(lbl_id)
        self.detail_box.append(lbl_credit)
        self.detail_box.append(lbl_debit)
        self.detail_box.append(lbl_net)
        self.detail_box.append(lbl_assigned)
        self.detail_box.append(expenses_box)

    def show_error(self, message: str):
        self.hide_loading()
        self.status.set_text(message)

    def show_loading(self):
        self.spinner.show()
        self.spinner.start()

    def hide_loading(self):
        self.spinner.stop()
        self.spinner.hide()



import gi
import requests

gi.require_version("Gtk", "4.0")

from gi.repository import Gtk, Gio, Gdk
from app.i18n import t
from gi.repository import GLib

from app.views.friends_view import FriendsView
from app.presenters.friends_presenter import FriendsPresenter
from app.views.expenses_view import ExpensesView
from app.views.detail_expense_view import DetailExpenseView
from app.services.api_client import ApiClient


class MainWindow(Gtk.ApplicationWindow):

    def __init__(self, self_app):
        super().__init__(application=self_app, title=t("app_title"))
        self.set_default_size(900, 600)

        #CSS para estilos
        css_provider = Gtk.CssProvider()
        css_provider.load_from_path("style.css")
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Layout (antes de comprobar conexion)
        main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        self.set_child(main_box)
        
        #Barra lateral 
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        sidebar.set_size_request(200, -1)
        sidebar.add_css_class("sidebar")
        #titulos
        title_button = Gtk.Button(label=t("app_title"))
        title_button.add_css_class("sidebar-title")
        title_button.set_has_frame(False)
        title_button.connect("clicked", self.show_home)
        sidebar.append(title_button)
        #botones barra lateral
        self.friends_button = Gtk.Button(label=t("friends_section"))
        self.friends_button.add_css_class("sidebar-button")

        self.expenses_button = Gtk.Button(label=t("expenses_section"))
        self.expenses_button.add_css_class("sidebar-button")
        #añadir botones a la barra
        sidebar.append(self.friends_button)
        sidebar.append(self.expenses_button)

        #Area de contenido
        self.stack = Gtk.Stack()
        self.stack.set_vexpand(True)
        self.stack.set_hexpand(True)
        #api client
        self.api_client = ApiClient("http://127.0.0.1:8000")
        #vistas y presenters
        self.friends_view = FriendsView(self.api_client)
        self.friends_presenter = FriendsPresenter(self.friends_view, self.api_client)
        self.expenses_view = ExpensesView(self.api_client, parent_window=self)
        #añadimos pantallas al stack 
        self.stack.add_titled(self.friends_view, "amigos", t("friends_section"))
        self.stack.add_titled(self.expenses_view, "gastos", t("expenses_section"))

        #inicio
        welcome_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=30)
        welcome_box.set_vexpand(True)
        welcome_box.set_hexpand(True)
        welcome_box.set_halign(Gtk.Align.CENTER)
        welcome_box.set_valign(Gtk.Align.CENTER)
        #titulo y subtitulo de bienvenida
        big_title = Gtk.Label(label=t("welcome_title"))
        big_title.set_margin_top(60)
        big_title.set_xalign(0.5)
        big_title.set_css_classes(["big-title"])  

        subtitle = Gtk.Label(label=t("welcome_subtitle"))
        subtitle.set_xalign(0.5)
        subtitle.set_css_classes(["subtitle"]) 
        
        #boton crear gasto
        btn_create = Gtk.Button(label=t("welcome_create_expense"))
        btn_create.connect("clicked", self.expenses_view.on_add_clicked)
        
        welcome_box.append(big_title)
        welcome_box.append(subtitle)
        welcome_box.append(btn_create)

        #añadir pantalla bienvenida 
        self.stack.add_titled(welcome_box, "bienvenida/o", t("welcome_title"))
        self.stack.set_visible_child_name("bienvenida/o")
        #conexion botones barra lateral
        self.friends_button.connect("clicked", self.show_friends)
        self.expenses_button.connect("clicked", self.show_expenses)
        #layout 
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        content_box.append(self.stack)
        #area de contenido 
        main_box.append(sidebar)
        main_box.append(content_box)


        # Comprobar conexion al servidor dps de mostrar la ventana principal
        def check_server(): 
            try:
                test_client = ApiClient("http://127.0.0.1:8000") #test conexiion
                test_client._session.get( 
                    test_client._url("/friends/"),
                    timeout=2
                )
            except Exception: #dialogo de error si no hay conexion
                dialog = Gtk.MessageDialog( 
                    message_type=Gtk.MessageType.ERROR, 
                    buttons=Gtk.ButtonsType.NONE,
                    text=t("server_error_offline"), 
                )
                dialog.set_default_size(350, 120) 

                # boton traducido
                dialog.add_button(t("accept"), Gtk.ResponseType.OK)

                def _on_response(dlg, _response_id): #cerrar app
                    app = Gtk.Application.get_default()  
                    if app is not None:
                        app.quit()
                    else:
                        self.close()

                dialog.connect("response", _on_response)
                dialog.present()

            return False #devolvemos false para evitar bucle infinito

        GLib.idle_add(check_server) #comprobar conexion


    # Acciones de la barra
    def show_home(self, button): #cambia a pantalla de bienvenida
        self.stack.set_visible_child_name("bienvenida/o")

    def show_friends(self, button): #pantalla amigos
        self.stack.set_visible_child_name("amigos")
        self.friends_presenter.load_friends() #recarga cuando hay cambios

    def show_expenses(self, button): #pantalla gastos
        self.stack.set_visible_child_name("gastos")
        self.expenses_view.presenter.load_expenses() #recarga cuando hay cambios

    def show_expense_detail(self, expense_id): #pantalla detalle gasto 
        detail_view = DetailExpenseView(self.api_client, expense_id, on_back=self.show_expenses) #volver a gastos
        self.stack.add_titled(detail_view, f"expense_{expense_id}", f"expense {expense_id}") #añade vista detalle
        self.stack.set_visible_child(detail_view) #cambia a vista detalle




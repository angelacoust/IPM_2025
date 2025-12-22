from typing import Any
from gi.repository import GLib

from app.presenters.base_presenter import BasePresenter



class FriendsPresenter(BasePresenter):
    """
    Lógica de la vista Friends.
    """

    def load_friends(self, query: str = ""):
        """
        Carga amigos del backend en un hilo.
        Aplica recursividad (aplanado) antes de pintar.
        Filtra por nombre si se da `query`.
        """
        # carga la lista de amigos desde el servidor y la prepara para mostrar en la vista
        def _load():
            # obtiene la lista de amigos del backend mediante una llamada http
            friends = self.api.list_friends()
            

            # si el usuario introduce texto en la busqueda filtra los nombres localmente
            if query:
                q = query.strip().lower()
                friends = [
                    f for f in friends
                    if q in str(f.get("name", "")).lower()
                ]

            # actualiza la vista con la lista final de amigos dentro del hilo principal de gtk
            GLib.idle_add(self.view.show_friends, friends)

        # ejecuta el proceso de carga en un hilo para no bloquear la interfaz
        self.safe_call_threaded(_load)

    def select_friend(self, friend_id: Any):
        """
        Carga detalle del amigo + sus gastos.
        """
        # carga la informacion completa de un amigo junto con los gastos asociados
        def _select():
            # obtiene los datos del amigo segun su identificador
            friend = self.api.get_friend(friend_id)
            # obtiene los gastos donde participa el amigo
            expenses = self.api.list_friend_expenses(friend_id)
            # agrega la lista de gastos al diccionario del amigo
            friend["expenses"] = expenses
            # actualiza la interfaz para mostrar el detalle del amigo
            GLib.idle_add(self.view.show_friend_detail, friend)

        # ejecuta la carga del detalle en un hilo separado
        self.safe_call_threaded(_select)


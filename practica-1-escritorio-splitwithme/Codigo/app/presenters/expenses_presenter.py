from gi.repository import GLib
from app.presenters.base_presenter import BasePresenter



class ExpensesPresenter(BasePresenter):
    """
    Presenter de la vista de gastos.
    - Mantiene el último filtro (_last_query).
    - Siempre obtiene la lista completa del backend.
    - Aplica filtrado local (como haces ya con friends).
    - Aplana recursivamente por si en el futuro hay subgastos.
    """

    def __init__(self, view, api_client):
        super().__init__(view, api_client)
        self._last_query = ""  # última búsqueda usada en la UI

    def load_expenses(self, query_text: str | None = None):
        """
        Carga y pinta la lista de gastos.

        Semántica:
        - query_text is None  -> reutiliza el último filtro guardado (_last_query)
                                 (esto se usa en Recargar, borrar gasto, etc.)
        - query_text is ""    -> sin filtro
        - query_text is "algo"-> filtrar por "algo"
        """

        # determina el texto de busqueda que se usara para filtrar los gastos
        if query_text is None:
            q = self._last_query
        else:
            q = (query_text or "").strip()
            self._last_query = q  # guarda el ultimo filtro usado

        def _work():
            # obtiene todos los gastos del backend siempre sin depender de filtrado del servidor
            data = self.api.list_expenses()

            # normaliza la respuesta a una lista para evitar errores si el backend devuelve un solo dict
            if isinstance(data, dict):
                expenses_list = [data]
            elif isinstance(data, (list, tuple)):
                expenses_list = list(data)
            else:
                expenses_list = []

           
            # aplica el filtro local si el usuario introdujo texto en la busqueda
            if q:
                q_lower = q.lower()

                if q.isdigit():
                    # busca por id exacto cuando el texto es solo numerico
                    expenses_list = [
                        e for e in expenses_list
                        if str(e.get("id", "")).strip() == q
                    ]
                else:
                    # busca por coincidencias en descripcion fecha o monto
                    expenses_list = [
                        e for e in expenses_list
                        if q_lower in str(e.get("description", "")).lower()
                        or q_lower in str(e.get("date", "")).lower()
                        or q_lower in str(e.get("amount", "")).lower()
                    ]

            # actualiza la interfaz grafica en el hilo principal de gtk
            def _ui():
                if hasattr(self.view, "show_expenses"):
                    self.view.show_expenses(expenses_list)
                elif hasattr(self.view, "update_expenses_table"):
                    self.view.update_expenses_table(expenses_list)
                else:
                    # muestra error si la vista no tiene ningun metodo para mostrar los datos
                    if hasattr(self.view, "show_error"):
                        self.view.show_error("No hay método show_expenses en ExpensesView.")
                return False

            GLib.idle_add(_ui)

        # ejecuta el proceso en segundo plano con proteccion de spinner y bloqueo de acciones repetidas
        self.safe_call_threaded(_work)

    def update_expense(self, expense_id, data: dict):
        """
        Actualiza un gasto y refresca la lista manteniendo el filtro activo.
        """
        def _work():
            # llama a la api para actualizar el gasto especificado
            self.api.update_expense(expense_id, data)

            # recarga la lista manteniendo el ultimo filtro aplicado
            def _ui():
                self.load_expenses()
                return False
            GLib.idle_add(_ui)

        # ejecuta la operacion en hilo separado y muestra mensaje de exito al terminar
        self.safe_call_threaded(_work, "Gasto actualizado correctamente.")

    def delete_expense(self, expense_id):
        """
        Borra un gasto y refresca la lista manteniendo el filtro activo.
        """
        def _work():
            # elimina el gasto del backend segun su id
            self.api.delete_expense(expense_id)

            # recarga la lista usando el mismo filtro actual
            def _ui():
                self.load_expenses()
                return False
            GLib.idle_add(_ui)

        # ejecuta la operacion en segundo plano y muestra mensaje de confirmacion
        self.safe_call_threaded(_work, "Gasto eliminado.")

    def add_expense(self, description: str, amount: float):
        """
        Crea un gasto y refresca la lista manteniendo el filtro activo.
        Ajusta date si tu ApiClient.create_expense necesita otra firma.
        """
        def _work():
            # crea un nuevo gasto usando los datos proporcionados
            self.api.create_expense(
                description=description,
                date="2025-10-06",
                amount=float(amount),
            )

            # recarga la lista de gastos para reflejar el nuevo registro
            def _ui():
                self.load_expenses()
                return False
            GLib.idle_add(_ui)

        # ejecuta la creacion del gasto en hilo secundario y muestra mensaje de exito
        self.safe_call_threaded(_work, "Gasto añadido correctamente.")


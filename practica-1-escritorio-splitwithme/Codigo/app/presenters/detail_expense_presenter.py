from gi.repository import GLib
from app.presenters.base_presenter import BasePresenter



class DetailExpensePresenter(BasePresenter):
    """
    Presenter del detalle de un gasto.
    - Cargar info del gasto y amigos asociados.
    - Actualizar crédito de un amigo.
    - Eliminar un amigo del gasto.
    - Añadir un amigo al gasto.
    Cada acción bloqueante va en hilo con safe_call_threaded para no congelar la UI.
    """

    def load_expense_detail(self, expense_id):
        """
        1. GET /expenses/{expense_id}
        2. GET /expenses/{expense_id}/friends
        3. Pintar ambos en la vista.
        """
        # carga la informacion completa de un gasto especifico y los amigos asociados
        def _work():
            # obtiene el gasto desde la api segun su id
            expense = self.api.get_expense(expense_id)
            # obtiene la lista de amigos asociados a ese gasto
            friends = self.api.list_friends_by_expense(expense_id)

            

            # actualiza los datos en la interfaz grafica dentro del hilo principal
            GLib.idle_add(self.view.show_expense_detail, expense)
            GLib.idle_add(self.view.show_friends, friends)

        # ejecuta la carga en un hilo secundario para no bloquear la interfaz
        self.safe_call_threaded(_work)

    def update_credit(self, expense_id, friend_id):
        """
        Flujo:
        - Mostrar diálogo para pedir nueva cantidad.
        - PUT al backend.
        - Refresco con ligero delay para garantizar que balances/num_friends estén ya recalculados.
        """

        # actualiza el credito de un amigo dentro de un gasto
        def after_dialog(dialog_result: dict | None):
            # valida que el resultado del dialogo tenga el campo amount
            if not dialog_result or "amount" not in dialog_result:
                return

            new_amount = dialog_result["amount"]

            # define la funcion que hara la llamada al backend
            def _work():
                # actualiza el credito en la api
                self.api.update_friend_credit(expense_id, friend_id, new_amount)

                # refresca la vista despues de un breve retardo
                def _delayed_refresh():
                    self.load_expense_detail(expense_id)
                    return False
                GLib.timeout_add(150, _delayed_refresh)

            # ejecuta la actualizacion en segundo plano y muestra mensaje de exito
            self.safe_call_threaded(_work, "Crédito actualizado.")

        # abre el dialogo para pedir la nueva cantidad al usuario
        self.view.show_update_credit(after_dialog)

    def delete_friend(self, expense_id, friend_id):
        """
        Elimina la relación de ese amigo con el gasto.
        Luego recarga con delay corto.
        """
        # elimina un amigo del gasto seleccionado
        def _work():
            # ejecuta la llamada de eliminacion en la api
            self.api.delete_friend_from_expense(expense_id, friend_id)

            # vuelve a cargar el detalle del gasto con un pequeño retraso
            def _delayed_refresh():
                self.load_expense_detail(expense_id)
                return False
            GLib.timeout_add(150, _delayed_refresh)

        # ejecuta la eliminacion en hilo separado y muestra mensaje de exito
        self.safe_call_threaded(_work, "Amigo eliminado del gasto.")

    def add_friend(self, expense_id):
        """
        Flujo:
        - Mostrar diálogo con amigos que aún no están en el gasto.
        - POST al backend para asociar el amigo.
        - Recargar con delay corto.
        """
        # agrega un nuevo amigo al gasto actual
        def after_dialog(dialog_result: dict | None):
            # comprueba que se haya recibido un friend_id valido
            if not dialog_result or "friend_id" not in dialog_result:
                return

            new_friend_id = dialog_result["friend_id"]

            # define la funcion para agregar el amigo en el backend
            def _work():
                self.api.add_friend_to_expense(expense_id, new_friend_id)

                # recarga el detalle del gasto despues de agregar el amigo
                def _delayed_refresh():
                    self.load_expense_detail(expense_id)
                    return False
                GLib.timeout_add(150, _delayed_refresh)

            # ejecuta la asociacion en hilo separado con mensaje de confirmacion
            self.safe_call_threaded(_work, "Amigo añadido al gasto.")

        # muestra el dialogo para seleccionar el amigo que se desea agregar
        self.view.show_add_friend(after_dialog)


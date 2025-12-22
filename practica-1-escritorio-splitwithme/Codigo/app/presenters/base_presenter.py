import threading
from gi.repository import GLib
from app.i18n import t


class BasePresenter:
    """
    Clase base para los presenters.
    - Ejecuta llamadas bloqueantes en un hilo aparte.
    - Sincroniza las actualizaciones de UI en el hilo GTK principal con GLib.idle_add.
    - Evita reentrancia (una operación a la vez por vista).
    """

    def __init__(self, view, api_client):
        # guarda la referencia a la vista y al cliente de api que usaran los presenters concretos
        self.view = view
        self.api = api_client
        # indica si hay una operacion en curso para evitar ejecuciones simultaneas
        self._busy = False  # una operación concurrente por vista

    def _notify_error(self, err: Exception):
        """
        Notificación de error unificada.
        Prioridad:
        1. show_error_dialog(texto) si la vista lo implementa
        2. show_error(texto) si no hay diálogo modal
        """
        def _ui():
            # convierte el error a texto y si detecta conflicto 409 lo cambia por un mensaje claro
            error_text = str(err)
            if "409" in error_text or "Conflict" in error_text:
                error_text = t("cannot_delete_friend_with_credit")

            # se prepara el mensaje final que mostrara la vista
            msg = error_text

            # muestra el mensaje en el metodo disponible de la vista
            if hasattr(self.view, "show_error_dialog"):
                self.view.show_error_dialog(msg)
            elif hasattr(self.view, "show_error"):
                self.view.show_error(msg)

        # ejecuta la actualizacion de la interfaz en el hilo principal de gtk
        from gi.repository import GLib
        GLib.idle_add(_ui)


    def _finish_op(self):
        """
        Se llama siempre al terminar una operación (éxito o error).
        Libera el flag de ocupado y quita spinner si existe.
        """
        def _ui():
            # marca la vista como libre para nuevas operaciones
            self._busy = False
            # si la vista tiene un metodo para ocultar el indicador de carga se llama aqui
            if hasattr(self.view, "hide_loading"):
                self.view.hide_loading()
        # garantiza que esta parte se ejecute en el hilo principal de gtk
        GLib.idle_add(_ui)

    def safe_call_threaded(self, func, success_msg: str | None = None):
        """
        Lanza `func` en un hilo.
        - Bloquea la vista contra toques repetidos (_busy).
        - Muestra spinner (show_loading) si la vista lo soporta.
        - Al terminar, llama hide_loading() y opcionalmente muestra mensaje de éxito.
        """
        # si ya hay una operacion en curso no se permite iniciar otra
        if self._busy:
            return

        # marca la vista como ocupada
        self._busy = True

        # muestra el indicador de carga si la vista lo soporta
        if hasattr(self.view, "show_loading"):
            self.view.show_loading()

        def worker():
            try:
                # ejecuta la funcion pasada en segundo plano
                result = func()

                # si se proporciono un mensaje de exito se muestra al finalizar correctamente
                if success_msg:
                    def _ok():
                        # muestra el mensaje en la barra de estado o en el metodo de error si no existe otro
                        if hasattr(self.view, "show_status"):
                            self.view.show_status(success_msg)
                        elif hasattr(self.view, "show_error"):
                            self.view.show_error(success_msg)
                    GLib.idle_add(_ok)

                return result

            except Exception as e:
                # si ocurre una excepcion se muestra un mensaje de error mediante la funcion correspondiente
                self._notify_error(e)
                return None

            finally:
                # cuando termina la tarea se limpia el estado de ocupado y se oculta el spinner
                self._finish_op()

        # inicia el hilo de trabajo en modo demonio para no bloquear la aplicacion
        threading.Thread(target=worker, daemon=True).start()

    # alias de compatibilidad que redirige safe_call al metodo con hilo
    def safe_call(self, func, success_msg: str | None = None):
        return self.safe_call_threaded(func, success_msg)


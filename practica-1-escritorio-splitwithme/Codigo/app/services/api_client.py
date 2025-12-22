import requests


class ApiClient:
    """
    Cliente HTTP hacia tu servidor FastAPI.

    Endpoints asumidos:
      - GET /friends/
      - GET /friends/{id}/
      - GET /friends/{id}/expenses/
      - GET /expenses/
      - GET /expenses/{id}/
      - POST /expenses/
      - PUT /expenses/{id}/
      - DELETE /expenses/{id}/
    """

    def __init__(self, base_url: str = "http://127.0.0.1:8000", timeout_s: float = 10.0):
        # configura la url base del servidor y el tiempo de espera maximo para las peticiones
        self._base_url = base_url.rstrip("/")
        self._timeout_s = timeout_s
        # crea una sesion http reutilizable para todas las llamadas al backend
        self._session = requests.Session()

    # ---- Helper interno ----
    def _url(self, endpoint: str) -> str:
        """Concatena correctamente la base URL y el endpoint."""
        # construye la direccion completa combinando la url base con el endpoint recibido
        return f"{self._base_url}/{endpoint.lstrip('/')}"

    # ---- Friends ----
    def list_friends(self):
        # obtiene la lista completa de amigos desde el backend
        r = self._session.get(self._url("/friends/"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    def get_friend(self, friend_id: int | str):
        # obtiene los datos de un amigo segun su identificador
        r = self._session.get(self._url(f"/friends/{friend_id}/"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    def list_friend_expenses(self, friend_id: int | str):
        # obtiene la lista de gastos asociados a un amigo especifico
        r = self._session.get(self._url(f"/friends/{friend_id}/expenses/"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    # ---- Expenses ----
    def list_expenses(self, query: str | None = None):
        """Obtiene los gastos desde el backend, opcionalmente filtrando por ID o descripción."""
        # trae los gastos del backend con o sin filtro de busqueda
        if query:
            if query.isdigit():
                # si el texto de busqueda es un numero busca un gasto por id
                r = self._session.get(self._url(f"/expenses/{query}"), timeout=self._timeout_s)
                r.raise_for_status()
                return [r.json()]
            else:
                # si el texto no es numerico busca por descripcion u otros campos
                r = self._session.get(self._url("/expenses/"), params={"search": query}, timeout=self._timeout_s)
                r.raise_for_status()
                return r.json()
        else:
            # si no hay texto de busqueda devuelve todos los gastos
            r = self._session.get(self._url("/expenses/"), timeout=self._timeout_s)
            r.raise_for_status()
            return r.json()

    def get_expense(self, expense_id):
        # obtiene el detalle de un gasto por su id
        r = self._session.get(self._url(f"/expenses/{expense_id}/"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    def list_friends_by_expense(self, expense_id):
        # obtiene los amigos asociados a un gasto especifico
        r = self._session.get(self._url(f"/expenses/{expense_id}/friends"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    def add_friend_to_expense(self, expense_id, friend_id):
        # agrega un amigo a un gasto mediante una llamada post al backend
        r = self._session.post(
            self._url(f"/expenses/{expense_id}/friends"),
            params={"friend_id": friend_id},
            timeout=self._timeout_s
        )
        r.raise_for_status()
        return r.json()

    def update_friend_credit(self, expense_id, friend_id, amount):
        # actualiza el credito de un amigo dentro de un gasto
        r = self._session.put(
            self._url(f"/expenses/{expense_id}/friends/{friend_id}"),
            params={"amount": amount},
            timeout=self._timeout_s
        )
        r.raise_for_status()
        return r.status_code

    def delete_friend_from_expense(self, expense_id, friend_id):
        # elimina la relacion de un amigo con un gasto determinado
        r = self._session.delete(self._url(f"/expenses/{expense_id}/friends/{friend_id}"), timeout=self._timeout_s)
        r.raise_for_status()
        return r.status_code == 204

    def create_expense(self, description: str, date: str, amount: float):
        """Crea un nuevo gasto."""
        # crea un nuevo gasto en el backend con los datos proporcionados
        data = {
            "description": description,
            "date": date,
            "amount": amount,
            "credit_balance": 0.0,
            "num_friends": 1
        }
        r = self._session.post(self._url("/expenses/"), json=data, timeout=self._timeout_s)
        r.raise_for_status()
        return r.json()

    def update_expense(self, expense_id: int | str, data: dict):
        """Actualiza un gasto existente."""
        # actualiza un gasto existente en el backend quitando el campo id si lo incluye
        data.pop("id", None)
        data.setdefault("credit_balance", 0.0)
        data.setdefault("num_friends", 1)
        r = self._session.put(self._url(f"/expenses/{expense_id}/"), json=data, timeout=self._timeout_s)
        r.raise_for_status()
        return r.json() if r.text else {}

    def delete_expense(self, expense_id: int | str):
        """Elimina un gasto."""
        # elimina un gasto en el backend segun su identificador
        r = self._session.delete(self._url(f"/expenses/{expense_id}/"), timeout=self._timeout_s)
        r.raise_for_status()
        return {"deleted": expense_id}

    # ---- Util ----
    def close(self):
        """Cierra la sesión HTTP limpia y segura."""
        # cierra la sesion http de manera segura manejando posibles excepciones
        try:
            self._session.close()
        except Exception:
            pass

    def __del__(self):
        # cierra la sesion automaticamente cuando el objeto se destruye
        self.close()


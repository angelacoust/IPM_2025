# Diseño Software — SplitWithMe (Patrón MVP)

## 1. Introducción
El presente diseño software sigue el patrón **Modelo–Vista–Presentador (MVP)**. 
Se incluyen los diagramas UML de la parte **estática** (estructura de clases) 
y la parte **dinámica** (interacción entre objetos) para cubrir los **CU1–CU11** definidos.

---

## 2. Diagrama estático (UML de clases)

```mermaid
classDiagram
direction TB

%% ==== VISTA (GTK4) ====
class IFriendsView {
  +show_friends(friends)
  +show_friend_detail(friend)
  +show_error(msg)
}
class IExpensesView {
  +show_expenses(expenses)
  +show_expense_detail(expense)
  +show_error(msg)
}
class FriendsView {
  +on_select_friend(id)
  +on_add_friend()
}
class ExpensesView {
  +on_create_expense()
  +on_select_expense(id)
  +on_edit_expense()
  +on_delete_expense()
}
FriendsView ..|> IFriendsView
ExpensesView ..|> IExpensesView

%% ==== PRESENTADOR ====
class FriendsPresenter {
  +load_friends()
  +show_friend_detail(id)
  +load_expenses_by_friend(id)
}
class ExpensesPresenter {
  +list_expenses()
  +create_expense()
  +update_expense(id)
  +delete_expense(id)
  +view_expense_detail(id)
}
FriendsPresenter --> IFriendsView
FriendsPresenter --> ApiClient
ExpensesPresenter --> IExpensesView
ExpensesPresenter --> ApiClient
BasePresenter <|-- FriendsPresenter
BasePresenter <|-- ExpensesPresenter

%% ==== MODELO (Backend SQLModel) ====
class Friend {
  -id:int
  -name:String
  -credit_balance:float
  -debit_balance:float
}
class Expense {
  -id:int
  -description:String
  -date:Date
  -amount:float
  -num_friends:int
}
class FriendExpenseLink {
  -friend_id:int
  -expense_id:int
  -amount:float
}
class Message {
  -detail:String
}
class ApiClient {
  +list_friends()
  +get_friend(id)
  +list_expenses()
  +create_expense(desc,date,amount)
  +update_expense(id,data)
  +delete_expense(id)
}
class AppConfig {
  +api_url:String
}

ApiClient --> AppConfig : usa configuración
Friend "1" --> "*" FriendExpenseLink : participa
Expense "1" --> "*" FriendExpenseLink : incluye
FriendExpenseLink --> Friend
FriendExpenseLink --> Expense
ExpensesPresenter --> Expense
FriendsPresenter --> Friend
ApiClient --> Friend
ApiClient --> Expense

```

---

## 3. Diagrama dinámico (UML de secuencia — Caso de uso “Crear gasto”)

```mermaid
sequenceDiagram
actor Usuario
participant Vista as ExpensesView <<VISTA>>
participant Presentador as ExpensesPresenter <<PRESENTADOR>>
participant Modelo as ApiClient <<MODELO (Frontend)>>
participant Backend as FastAPI <<MODELO (Backend)>>
participant BD as Base de Datos (SQLite)

Usuario ->> Vista: Introduce descripción, fecha y cantidad
Vista ->> Vista: Valida campos (no vacíos)
Vista ->> Presentador: create_expense(descripción, fecha, cantidad)
Presentador ->> Modelo: create_expense(data)
Modelo ->> Backend: POST /expenses {description, date, amount}
Backend ->> BD: Inserta nuevo gasto
BD -->> Backend: Confirma creación con ID
Backend -->> Modelo: JSON {id, description, date, amount}
Modelo -->> Presentador: Objeto Expense creado
Presentador ->> Vista: show_new_expense(expense)
Vista ->> Usuario: Muestra el nuevo gasto en la lista

```

---

## 4. Trazabilidad Casos de Uso → Clases

| CU | Vista | Presentador | Modelo |
|----|--------|--------------|---------|
| CU1–CU3 | FriendsView | FriendsPresenter | ApiClient, Friend, FriendExpenseLink |
| CU4–CU11 | ExpensesView | ExpensesPresenter | ApiClient, Expense, Friend, FriendExpenseLink |

---

## 5. Conclusión
El diseño propuesto sigue el patrón MVP, garantizando separación entre la interfaz (Vista), la lógica de control (Presentador) y la lógica de negocio (Modelo). 
Permite implementar todos los casos de uso definidos y mantener un acoplamiento bajo entre las capas.

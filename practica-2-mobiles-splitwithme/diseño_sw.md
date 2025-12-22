# Diseño Software — SplitWithFriends (Patrón MVVM)

## 1. Introducción

El presente diseño software sigue el patrón arquitectónico **Modelo–Vista–ViewModel (MVVM)**.  
Este patrón permite **separar claramente la interfaz de usuario, la lógica de interacción y el acceso a datos**, evitando dependencias innecesarias y facilitando el mantenimiento.

---

## 2. Diagrama estático (UML de clases)

```mermaid
classDiagram

class Friend {
  +id: String
  +name: String
  +creditTotal: double
  +debitTotal: double
  +netBalance(): double
}

class Expense {
  +id: String
  +description: String
  +date: DateTime
  +amount: double
  +participants: List<Participant>
}

class Participant {
  +friendId: String
  +credit: double
  +debit: double
}

Friend --> Participant : referenced by
Expense --> Participant : contains


class SplitWithFriendsService {
  <<abstract>>
  +fetchFriends()
  +fetchExpenses()
  +createExpense(expense)
  +addFriendToExpense(expenseId, friendId)
  +updateCredit(expenseId, friendId, amount)
}

class APIService {
  +serverUrl: String
  +implements REST calls
}

class FriendRepository {
  -service: SplitWithFriendsService
  +getFriends(): Future<List<Friend>>
}

class ExpenseRepository {
  -service: SplitWithFriendsService
  +getExpenses(): Future<List<Expense>>
  +createExpense(expense): Future
  +addFriend(expenseId, friendId): Future
  +updateCredit(expenseId, friendId, amount): Future
}

APIService --|> SplitWithFriendsService
FriendRepository --> SplitWithFriendsService
ExpenseRepository --> SplitWithFriendsService


class FriendsVM {
  +friends: List<Friend>
  +loadFriends(): Command0
}

class ExpenseDetailVM {
  +expense: Expense
  +addFriend(expenseId, friendId): Command1
  +updateCredit(expenseId, friendId, amount): Command1
}

FriendsVM --> FriendRepository
ExpenseDetailVM --> ExpenseRepository


class FriendsScreen {
  +viewModel: FriendsVM
  +build()
}

class ExpenseDetailScreen {
  +viewModel: ExpenseDetailVM
  +build()
}

FriendsScreen --> FriendsVM
ExpenseDetailScreen --> ExpenseDetailVM

```

---

## 3. Diagrama dinámico (UML de secuencia — Caso de uso “Crear gasto”)

```mermaid

sequenceDiagram
    autonumber
    participant Usuario
    participant CreateExpenseScreen
    participant CreateExpenseViewModel
    participant ExpenseRepository
    participant Service as SplitWithFriendsService
    participant BackendDB as Base de Datos / API

    Usuario ->> CreateExpenseScreen: Introduce descripción, fecha e importe
    CreateExpenseScreen ->> CreateExpenseScreen: Validar campos

    %% Error de validación
    CreateExpenseScreen -->> CreateExpenseScreen: Error: datos inválidos

    %% Si es válido continúa
    CreateExpenseScreen ->> CreateExpenseViewModel: create(description, date, amount)

    CreateExpenseViewModel ->> ExpenseRepository: createExpense(new Expense)
    ExpenseRepository ->> Service: createExpense(expense)
    Service ->> BackendDB: Insertar nuevo gasto

    %% Error en API / red
    Service -->> CreateExpenseViewModel: Error en la petición
    CreateExpenseViewModel -->> CreateExpenseScreen: Mostrar error

    %% Error en base de datos
    BackendDB -->> Service: Error interno
    Service -->> ExpenseRepository: Excepción
    ExpenseRepository -->> CreateExpenseViewModel: Error
    CreateExpenseViewModel -->> CreateExpenseScreen: Mostrar error

    %% Éxito
    BackendDB -->> Service: Confirmación (ID generado)
    Service -->> ExpenseRepository: OK
    ExpenseRepository -->> CreateExpenseViewModel: Gasto creado

    CreateExpenseViewModel ->> CreateExpenseScreen: notifyListeners()
    CreateExpenseScreen ->> Usuario: Mostrar gasto en la lista

```
---

## 4. Conclusión

Se utiliza el patrón **MVVM** porque:
- Separa de forma efectiva **UI**, **lógica de negocio** y **acceso a datos**.
- Permite que las **vistas sean simples y reactivas**, reaccionando automáticamente a los cambios de estado.
- La lógica permanece en la **ViewModel**, lo que facilita las **pruebas unitarias**.
- Los **repositorios** aíslan la fuente de datos, lo que permite intercambiar API, mocks o almacenamiento local sin modificar la UI.

Este diseño es **mantenible, escalable y adecuado** para aplicaciones móviles desarrolladas con Flutter.


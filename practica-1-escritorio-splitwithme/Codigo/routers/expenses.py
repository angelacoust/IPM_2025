from datetime import datetime
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select, func

from persistence.database import get_session
from persistence.models import Message, Friend, Expense, FriendExpenseLink

router = APIRouter(
    prefix="/expenses",
    tags=["expenses"]
)


# ----- MODELO PARA UPDATE -----
from pydantic import BaseModel


class ExpenseUpdate(BaseModel):
    description: str
    date: str
    amount: float
    # Lista de IDs de amigos que deben quedar asociados al gasto
    participants: Optional[List[int]] = None


def is_valid_date(date_str: str) -> bool:
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False


@router.post(
    "/",
    status_code=201,
    responses={201: {"model": Expense}, 409: {"model": Message}},
)
def add_expense(expense: Expense, session: Session = Depends(get_session)) -> Expense:
    if not is_valid_date(expense.date):
        raise HTTPException(
            status_code=422,
            detail=f"Malformed date '{expense.date}' (required format: YYYY-MM-DD)",
        )
    existing_expense = session.exec(
        select(Expense)
        .where(Expense.description == expense.description)
        .where(Expense.date == expense.date)
    )
    if existing_expense.first() is None:
        session.add(expense)
        session.commit()
        session.refresh(expense)
        return expense
    else:
        raise HTTPException(status_code=409, detail="Expense already exists")


def get_credit_balance(expense_id: int, session: Session) -> float:
    # Sum all the contributions of the expense
    credit_balance = session.exec(
        select(func.sum(FriendExpenseLink.amount)).where(
            FriendExpenseLink.expense_id == expense_id
        )
    ).first()
    if credit_balance is None:
        credit_balance = 0
    return credit_balance


def get_num_friends(expense_id: int, session: Session) -> float:
    # Get all the friends
    num_friends = session.exec(
        select(func.count(FriendExpenseLink.friend_id)).where(
            FriendExpenseLink.expense_id == expense_id
        )
    ).first()
    if num_friends is None:
        num_friends = 1
    return num_friends + 1


@router.get(
    "/{expense_id}",
    responses={200: {"model": Expense}, 404: {"model": Message}},
)
def get_expense(expense_id: int, session: Session = Depends(get_session)) -> Expense:
    results = session.exec(select(Expense).where(Expense.id == expense_id))
    expense = results.first()
    if expense is not None:
        expense.credit_balance = get_credit_balance(expense_id, session)
        return expense
    else:
        raise HTTPException(
            status_code=404, detail=f"Expense '{expense_id}' not found"
        )


@router.get(
    "/",
    responses={200: {"model": list[Expense]}, 404: {"model": Message}},
)
def get_expenses(session: Session = Depends(get_session)) -> list[Expense]:
    expenses = session.exec(select(Expense)).all()
    for expense in expenses:
        expense.credit_balance = get_credit_balance(expense.id, session)
        expense.num_friends = get_num_friends(expense.id, session)
    return expenses


@router.put(
    "/{expense_id}",
    status_code=204,
    responses={404: {"model": Message}},
)
def update_expense(
    expense_id: int, expense: ExpenseUpdate, session: Session = Depends(get_session)
):
    # Validar fecha
    if not is_valid_date(expense.date):
        raise HTTPException(
            status_code=422,
            detail=f"Malformed date '{expense.date}' (required format: YYYY-MM-DD)",
        )

    results = session.exec(select(Expense).where(Expense.id == expense_id))
    stored_expense = results.first()
    if stored_expense is None:
        raise HTTPException(
            status_code=404, detail=f"Expense {expense_id} not found"
        )

    # Actualizar campos básicos del gasto
    stored_expense.description = expense.description
    stored_expense.date = expense.date
    stored_expense.amount = expense.amount

    # ----- SINCRONIZAR PARTICIPANTES -----
    if expense.participants is not None:
        # 1) borrar los enlaces antiguos de este gasto
        old_links = session.exec(
            select(FriendExpenseLink).where(
                FriendExpenseLink.expense_id == expense_id
            )
        ).all()
        for link in old_links:
            session.delete(link)

        # 2) crear nuevos enlaces (amount 0 por defecto)
        for friend_id in expense.participants:
            link = FriendExpenseLink(
                expense_id=expense_id,
                friend_id=friend_id,
                amount=0,  # ajusta si quieres otro valor por defecto
            )
            session.add(link)

    session.commit()
    # 204 No Content: no devolvemos cuerpo


@router.delete(
    "/{expense_id}",
    status_code=204,
    responses={404: {"model": Message}},
)
def delete_expense(expense_id: int, session: Session = Depends(get_session)):
    results = session.exec(select(Expense).where(Expense.id == expense_id))
    stored_expense = results.first()
    if stored_expense is not None:
        session.delete(stored_expense)
        session.commit()
    else:
        raise HTTPException(
            status_code=404, detail=f"Expense '{expense_id}' not found"
        )


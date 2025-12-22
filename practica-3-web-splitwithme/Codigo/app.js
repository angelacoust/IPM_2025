// DATOS INICIALES 
 // los definimos aqui así para que la web no empiece vacia
let expenses = [
  {
    id: 1,
    title: "Viaje a Madrid",
    date: "2025-03-15",
    total: 250,
    //cada participante tiene su.nombre y el credito 
    participants: [
      { name: "Lucas", credit: 0 },
      { name: "Ana", credit: 0 },
      { name: "Miguel", credit: 0 }
    ]
  },
  {
    id: 2,
    title: "Cena de cumpleaños",
    date: "2025-04-02",
    total: 120,
    participants: [
      { name: "Lucas", credit: 0 },
      { name: "Joel", credit: 0 },
      { name: "Ángela", credit: 0 }
    ]
  },
  {
    id: 3,
    title: "Viaje a Parla",
    date: "2025-04-10",
    total: 0,
    participants: [
      { name: "Lucas", credit: 0 },
      { name: "Antonio", credit: 0 }
    ]
  }
];
//lista de maigos: aqui se acumulara el total global de lo que deben 
let friends = [
  { id: 1, name: "Lucas", credit: 0, debit: 0 },
  { id: 2, name: "Joel", credit: 0, debit: 0 },
  { id: 3, name: "Ángela", credit: 0, debit: 0 },
  { id: 4, name: "Antonio", credit: 0, debit: 0 },
  { id: 5, name: "Ana", credit: 0, debit: 0 },
  { id: 6, name: "Miguel", credit: 0, debit: 0 }
];

let filteredExpenses = [...expenses]; //copias de los arrays para gestionar las busquedas sin perder los datos originales
let filteredFriends = [...friends];

let currentExpenseSearch = ""; //variables para guardar el texto que el usuario escribe en las cajas de busqueda
let currentFriendSearch = "";

// Para saber el ID d que gasto esta abierto en el diálogo
let currentExpenseId = null;
// Para saber si estamos editando (id) o creando (null)
let editingExpenseId = null;

// REFERENCIAS DOM 
//creamos en variables elementos del html para poder manipularlos
const expensesListEl = document.querySelector(".expenses-list"); //contenedores de listas
const friendsListEl = document.querySelector(".friends-list");

const searchExpenseInput = document.getElementById("search-expense");//inputs de busqueda
const searchFriendInput = document.getElementById("search-friend");

const addExpenseButton = document.getElementById("add-expense-button"); //boton añadir gasto

const dialogAddExpense = document.getElementById("dialog-add-expense"); 
const dialogViewExpense = document.getElementById("dialog-view-expense");
const dialogViewFriend = document.getElementById("dialog-view-friend");
const addExpenseDialogTitle = dialogAddExpense ? dialogAddExpense.querySelector("h2") : null;
const addExpenseAcceptBtn = dialogAddExpense ? dialogAddExpense.querySelector(".accept") : null;


// Resumen
const resumenTotalGastosEl = document.querySelector(".summary-list__item:nth-child(1) dd");
const resumenNumActividadesEl = document.querySelector(".summary-list__item:nth-child(2) dd");
const resumenPersonaMasDebeEl = document.querySelector(".summary-list__item:nth-child(3) dd");

//RE-CALCULO DE SALDOS 

//toasts, mensajes temporales en pantalla para dar feedback
const toastEl = document.getElementById('toast');
let _toastTimer = null;
function showToast(message, ms = 3000) {
  if (!toastEl) return;
  // cancelar timer previo
  if (_toastTimer) {
    clearTimeout(_toastTimer);
    _toastTimer = null;
  }
  toastEl.textContent = message;
  toastEl.hidden = false;
  toastEl.setAttribute('data-show', 'true');
  // ocultar despues de 2 segundos
  _toastTimer = setTimeout(() => {
    toastEl.setAttribute('data-show', 'false');
    // permitir transicion y luego ocultar para AT
    setTimeout(() => {
      toastEl.hidden = true;
    }, 220);
    _toastTimer = null;
  }, ms);
}


// friends.credit y friends.debit se recalculan SIEMPRE desde los gastos
function recalcFriendBalances() {
  // Reiniciamos poniendo a 0 a todoos los amigos para no sumar dos eveces lo mismo 
  friends.forEach(f => {
    f.credit = 0; //lo que han pagado 
    f.debit = 0;//deben 
  });

  expenses.forEach(exp => { //recorremos los gastos 1 a 1
    if (!exp.participants || exp.participants.length === 0) return; //saltamos gasto sin participantes 

    const perPerson = exp.total / exp.participants.length; //calcula cuanto toca pagar por persona en el gasto 

    exp.participants.forEach(p => { //recorre los participates del gasto
      const fr = friends.find(f => f.name === p.name); //busca amigo en la lista general usando nombre
      if (!fr) return; //si no lo encuentra no hace nada

      //suma lo que este participante puso en este gasto al total de su credito 
      const participantCredit = p.credit || 0; // por si es undefined
      fr.credit += participantCredit;
      //suma la parte proporional que le toca pagar al total de su debito
      fr.debit += perPerson;
    });
  });
}

// RESUMEN DE GASTOS

function renderSummary() { //funcion para actualizar los datos del resumen general 
  const totalDinero = expenses.reduce((acc, e) => acc + e.total, 0); //dinero de todos los gastos
  const numActividades = expenses.length;

  recalcFriendBalances(); //antes de mostrar quien debe, debemos recalcular saldos para q esten actualizados

  const saldos = friends.map(f => ({ //Aarray temporal calculando balance final (debe-pagado)
    name: f.name,
    balance: f.debit - f.credit //si es positivo, debe dinero, si negativo, le deben 
  }));

  const maxBalance = Math.max(...saldos.map(s => s.balance)); //buscamos numero mas alto de deuda
  let textoDebe;

  if (!Number.isFinite(maxBalance) || maxBalance <= 0) { //si nadie debe nada o el numero es negativo / 0
    textoDebe = "Nadie debe";
  } else { //busca quienes son los que tienen esa deuda maxima por si hay empate
    const empatados = saldos.filter(s => s.balance === maxBalance);
    //crea texto ej: lucas , ana (20e)
    textoDebe =
      empatados.map(e => e.name).join(", ") + ` (${maxBalance.toFixed(2)} €)`;
  }

  //pinta resultados en el html si los elementos existen 
  if (resumenTotalGastosEl) resumenTotalGastosEl.textContent = `${totalDinero.toFixed(2)} €`;
  if (resumenNumActividadesEl) resumenNumActividadesEl.textContent = numActividades;
  if (resumenPersonaMasDebeEl) resumenPersonaMasDebeEl.textContent = textoDebe;
}

// RENDER GASTOS

function renderExpenses() { //pintar la lista de tarjetas de gastos 
  if (!expensesListEl) return; //proteccino por si no existe el elemento 

  expensesListEl.innerHTML = ""; //borra lo que hbia antes

  //si el filtro no devuelve nada, muestra mensaje
  if (filteredExpenses.length === 0) {
    const p = document.createElement("p");
    p.textContent = "No hay gastos que coincidan con el filtro.";
    expensesListEl.appendChild(p);
    renderSummary(); //actualiza el resumen aunque no haya lista
    return;
  }

  //bucle para crear una tarjeta por cada gasto filtrado 
  filteredExpenses.forEach(expense => {
    const card = document.createElement("article"); //crea el elemento tarjeta (article) (contenedor semantico )
    card.className = "expense-card"; 
 
    //inserta el html interno de la tarjeta usando template literals
    card.innerHTML = `
      <div class="expense-card__header">
        <div>
          <h3 class="expense-card__title">${expense.title}</h3>
          <p class="expense-card__meta">${expense.date} · ${expense.total.toFixed(2)} €</p>
        </div>
      </div>
      <p class="expense-card__participants">
        Participantes: ${(expense.participants || []).map(p => p.name).join(", ")}
      </p>
      <div style="display:flex; gap:0.5rem;">
        <button type="button" class="btn-primary btn-small view-btn">Ver detalles</button>
        <button type="button" class="btn-primary btn-small edit-btn">Editar</button>
        <button type="button" class="btn-secondary btn-small delete-btn">Eliminar</button>
      </div>
    `;

    //asignar la funcion de abrir de talles al boton ver detalles
    card.querySelector(".view-btn").addEventListener("click", () => {
      openExpenseDetail(expense.id);
    });
    //asigna la funcion deborrar al boton eliminar
    card.querySelector(".delete-btn").addEventListener("click", () => {
      if (!confirm(`¿Eliminar gasto "${expense.title}"?`)) return; //confirmacion de borrado
      //filtra el array original quitando el id
      expenses = expenses.filter(e => e.id !== expense.id);
      //aplica filtros otra vez y repinta todo 
      applyExpenseFilters();
      recalcFriendBalances();
      renderExpenses();
      renderFriends();
      renderSummary();
      // mensaje informativo
      try { 
        showToast('Gasto eliminado', 3000);  //mensaje temporal , 3 segundos (3000 ms)
      } catch (e) {
        //ignorar
      }
    });
    // boton editar: abre el diálogo de añadir con datos precargados
    const editBtn = card.querySelector('.edit-btn');
    if (editBtn) {
      editBtn.addEventListener('click', () => {
        const nameInput = document.getElementById('add-expense-name');
        const dateInput = document.getElementById('add-expense-date');
        const amountInput = document.getElementById('add-expense-amount');
        if (nameInput) nameInput.value = expense.title;
        if (dateInput) dateInput.value = expense.date;
        if (amountInput) amountInput.value = expense.total;
        // marcar que estamos en modo edición
        editingExpenseId = expense.id;
        // abrir diálogo
        // limpiar errores si existen
        const err = dialogAddExpense.querySelector('.form-error');
        if (err) err.textContent = '';
        if (addExpenseDialogTitle) addExpenseDialogTitle.textContent = "Editar gasto";
        if (addExpenseAcceptBtn) addExpenseAcceptBtn.textContent = "Guardar";

        openDialog(dialogAddExpense);
      });
    }
    //añadela tarjeta al dom
    expensesListEl.appendChild(card);
  });
  //actualiza resumen general al final 
  renderSummary(); 
}

// RENDER AMIGOS 

function renderFriends() { //funcion para pintar la lista de amigos
  if (!friendsListEl) return;
  //se asegura de tener los numeros atualizados
  recalcFriendBalances();
  friendsListEl.innerHTML = ""; //limpiamos la lista

  filteredFriends.forEach(friend => {
    const card = document.createElement("article");
    card.className = "friend-card";

    //crea html de la tarjeta del amigo mostrando credito y debito 
    card.innerHTML = `
      <div class="friend-card__header">
        <div class="friend-card__avatar" aria-hidden="true">👤</div> 
        <h3 class="friend-card__name">${friend.name}</h3>
      </div>
      <p class="friend-card__meta">
        <span>ID: ${friend.id}</span>
        <span>Crédito: ${friend.credit.toFixed(2)}€</span>
        <span>Débito: ${friend.debit.toFixed(2)}€</span>
      </p>
      <button type="button" class="btn-primary btn-small view-friend">Ver detalles</button>
    `;
    //boton para ver detalle del amigo 
    card.querySelector(".view-friend").addEventListener("click", () => {
      openFriendDetail(friend.id);
    });

    friendsListEl.appendChild(card); //añade tarjeta al dom
  });

  renderSummary(); //actualiza resumen general al final
}

//DETALLE GASTO

function openExpenseDetail(id) { //funcion que rellena el popup de detalle de gasto
  const expense = expenses.find(e => e.id === id); //busca el gasto en el array original por id 
  if (!expense || !dialogViewExpense) return;

  currentExpenseId = id; //guarda el id globalmente para sber que estamos editando 
  openDialog(dialogViewExpense); //muestra el popup
  //referencia a los elementos dentro del popup 
  const titleEl = dialogViewExpense.querySelector(".details-title strong");
  const metaSpans = dialogViewExpense.querySelectorAll(".details-expense-meta span");
  const participantsList = dialogViewExpense.querySelector(".details-participants");
  const creditDebitContainer = dialogViewExpense.querySelector(".details-credit-debit");

  //rellena titulo y datos del gasto 
  if (titleEl) titleEl.textContent = `${expense.id}. ${expense.title}`;
  if (metaSpans[0]) metaSpans[0].textContent = expense.date;
  if (metaSpans[1]) metaSpans[1].textContent = `${expense.total} €`;
  if (metaSpans[2]) metaSpans[2].textContent = `${(expense.participants || []).length} amigos`;
  //limpia listas de participantes y creditos/debitos
  participantsList.innerHTML = "";
  creditDebitContainer.innerHTML = "";
  //si no hay paraticipantes muestra mensaje avisando
  if (!expense.participants || expense.participants.length === 0) {
    const li = document.createElement("li");
    li.textContent = "Sin participantes.";
    participantsList.appendChild(li);
  } else { //calcua cuanto toca pagar por cabeza en el gasto
    const perPerson = expense.total / expense.participants.length;
    //recorre cada participante de este gasto 
    expense.participants.forEach(p => {
      const friend = friends.find(f => f.name === p.name);

      // Parte izquierda: participante + boton eliminar
      const li = document.createElement("li");
      li.innerHTML = `
        <span class="icon-person-circle" aria-hidden="true">👤</span> ${p.name}
      `;

      const removeBtn = document.createElement("button");
      removeBtn.type = "button";
      removeBtn.className = "btn-secondary btn-small remove-participant";
      removeBtn.textContent = "Eliminar";
      removeBtn.setAttribute("aria-label", `Eliminar ${p.name} del gasto`);
      removeBtn.style.marginLeft = "0.5rem";
      //logica para eliminar participante del gasto
      removeBtn.addEventListener("click", () => {
        const f = friends.find(ff => ff.name === p.name);
        if (!f) {
          alert("No se encontró el amigo.");
          return;
        }
        //no se puede borrar si el amigo ya puso dinero 
         
// no se puede borrar si el amigo ya puso dinero EN ESTE GASTO
if ((p.credit || 0) > 0) {
  alert("No se puede eliminar: el amigo tiene crédito superior a 0 en este gasto");
  return;
}
        //filtra para quitarlo del array de participantes
        expense.participants = expense.participants.filter(pp => pp.name !== p.name);
        //recalcula y repinta todo 
        recalcFriendBalances();
        applyExpenseFilters();
        applyFriendFilters();
        renderExpenses();
        renderFriends();
        renderSummary();
        //vuelve a llamar a esta funcion para refrescar el popup
        try { 
          showToast(`${p.name} eliminado del gasto`, 3000); 
        } catch (e) {
          //ignorar
        }
        openExpenseDetail(expense.id);
      });

      li.appendChild(removeBtn);
      participantsList.appendChild(li);

      //parte derecha: credito / debito + boton actualizar credito
      const row = document.createElement("div");
      row.className = "details-credit-debit-row";

      const currentCredit = p.credit || 0;

      row.innerHTML = `
        <span class="credit-amount">Crédito: ${currentCredit.toFixed(2)}€</span>
        <span>Débito: ${perPerson.toFixed(2)}€</span>
        <button type="button" class="btn-secondary btn-small update-credit">Actualizar</button>
      `;

      const updateBtn = row.querySelector(".update-credit");
      const creditLabel = row.querySelector(".credit-amount");
      //logica para cambiar cuanto pago esta persona
      updateBtn.addEventListener("click", () => {
        const amountStr = prompt(`¿Cuánto ha pagado ${p.name}?`, "0");
        if (amountStr === null) return; //si cancela no hace nada
        const amount = Number(amountStr);
        if (!Number.isFinite(amount)) {
          alert("Debe ser un número válido.");
          return;
        }

        // CRÉDITO ESPECÍFICO DE ESTE GASTO
        p.credit = (p.credit || 0) + amount;

        // Actualizar etiqueta de ESTE gasto
        creditLabel.textContent = `Crédito: ${(p.credit || 0).toFixed(2)}€`;

        // Recalcular globales a partir de todos los gastos
        recalcFriendBalances();
        renderFriends();
        renderSummary();
        try { 
          showToast(`Crédito actualizado para ${p.name}`, 3000); 
        } catch (e) {
          //ignorrar
        }
      });

      creditDebitContainer.appendChild(row);
    });
  }

  setupAddFriendToExpense(expense); //llama funcion auxiliar para configurar el select de añadir amigo 
}

// Configura el selector y botón de "añadir amigo" para el gasto actual
function setupAddFriendToExpense(expense) {
  const addSelect = dialogViewExpense.querySelector(".add-friend-select");
  let addBtn = dialogViewExpense.querySelector(".add-friend-btn");
  if (!addSelect || !addBtn) return;

  // Evitar múltiples listeners: clonar botón
  const newBtn = addBtn.cloneNode(true);
  addBtn.parentNode.replaceChild(newBtn, addBtn);
  addBtn = newBtn;
  //filtra amigos que no esten ya en el gasto 
  const availableFriends = friends.filter(f =>
    !(expense.participants || []).some(p => p.name === f.name)
  );

  addSelect.innerHTML = "";
  //si todos estan en el gasto, deshabilita el select
  if (availableFriends.length === 0) {
    addSelect.disabled = true;
    addBtn.disabled = true;
    const opt = document.createElement("option");
    opt.value = "";
    opt.textContent = "No hay más amigos";
    addSelect.appendChild(opt);
    return;
  }

  addSelect.disabled = false;
  addBtn.disabled = false;

  const placeholder = document.createElement("option");
  placeholder.value = "";
  placeholder.textContent = "Seleccionar amigo…";
  addSelect.appendChild(placeholder);
  //rellena el select con los amigos disponibles
  availableFriends.forEach(f => {
    const opt = document.createElement("option");
    opt.value = f.name;
    opt.textContent = f.name;
    addSelect.appendChild(opt);
  });
  //al hacer clic en añadir 
  addBtn.addEventListener("click", () => {
    const selectedName = addSelect.value;
    if (!selectedName) return;
    //recupera el gasto actual 
    const exp = expenses.find(e => e.id === currentExpenseId);
    if (!exp) return;

    if (!exp.participants) exp.participants = [];
    //comprobacion de seguridad
    if (exp.participants.some(p => p.name === selectedName)) {
      alert("Este amigo ya participa en el gasto.");
      return;
    }

    // NUEVO PARTICIPANTE CON CRÉDITO POR DEFECTO 0
    exp.participants.push({ name: selectedName, credit: 0 });
    //actualiza todo 
    recalcFriendBalances();
    applyExpenseFilters();
    applyFriendFilters();
    renderExpenses();
    renderFriends();
    renderSummary();
    //Recarga el detalle
    openExpenseDetail(exp.id);
    try {
      showToast(`Amigo añadido al gasto`, 3000); 
      } catch (e) {
          //ignorar
       }
  });
}

// DETALLE AMIGO

function openFriendDetail(id) { //funcion para mostrar popup con detalles
  const friend = friends.find(f => f.id === id);
  if (!friend || !dialogViewFriend) return;

  recalcFriendBalances(); //datos actualizados
  openDialog(dialogViewFriend);
  //Referencias al dom del popup de amigo 
  const titleEl = dialogViewFriend.querySelector(".friend-details__title strong");
  const summarySpans = dialogViewFriend.querySelectorAll(".friend-details__summary span");
  const expensesList = dialogViewFriend.querySelector(".friend-expenses");
  //Rellena cabecera
  if (titleEl) titleEl.textContent = `${friend.id}. ${friend.name}`;
  if (summarySpans[0]) summarySpans[0].textContent = `Crédito: ${friend.credit.toFixed(2)}€`;
  if (summarySpans[1]) summarySpans[1].textContent = `Débito: ${friend.debit.toFixed(2)}€`;
  //limpia lista de gastos
  expensesList.innerHTML = "";
  //filtra los gastos en los que participa este amigo
  const involvedExpenses = expenses.filter(e =>
    e.participants && e.participants.some(p => p.name === friend.name)
  );

  if (involvedExpenses.length === 0) {
    const li = document.createElement("li");
    li.textContent = "Este amigo no participa en ningún gasto.";
    expensesList.appendChild(li);
    return;
  }
  //lista los amigos encontrados
  involvedExpenses.forEach(exp => {
    const perPerson = exp.participants.length > 0
      ? exp.total / exp.participants.length
      : 0;

    const li = document.createElement("li");
    li.innerHTML = `
      <div class="friend-expense__left">
        <span class="icon-money-circle" aria-hidden="true">$</span>
        <span>${exp.id} - ${exp.title}</span>
      </div>
      <span class="friend-expense__amount">${perPerson.toFixed(2)}€</span>
    `;
    expensesList.appendChild(li);
  });
}

// FILTROS 
//logica para las barras de busqueda
function applyExpenseFilters() { 
  //filtra el array original y guarda resultado en el array filtrado
  const text = currentExpenseSearch.toLowerCase();
  filteredExpenses = expenses.filter(exp =>
    exp.title.toLowerCase().includes(text)
  );
}

function applyFriendFilters() {
  const text = currentFriendSearch.toLowerCase();
  filteredFriends = friends.filter(fr =>
    fr.name.toLowerCase().includes(text)
  );
}
//eventos para las cajas de busqueda
if (searchExpenseInput) {
  searchExpenseInput.addEventListener("input", (e) => {
    currentExpenseSearch = e.target.value || "";
    applyExpenseFilters();
    renderExpenses(); //repinta lista de gastos
  });
}
//evento para caja de busqueda amigos
if (searchFriendInput) {
  searchFriendInput.addEventListener("input", (e) => {
    currentFriendSearch = e.target.value || "";
    applyFriendFilters();
    renderFriends(); //repinta lista de amigos
  });
}

// DIÁLOGOS GENÉRICOS
//funciones para mostrar/ocultar popups
function openDialog(dialog) {
  dialog.hidden = false;
}

function closeDialog(dialog) {
  dialog.hidden = true;
}

//cerrar al pulsar x
document.querySelectorAll(".dialog__close").forEach(btn => {
  btn.addEventListener("click", () => {
    const dlg = btn.closest(".dialog");
    if (dlg) closeDialog(dlg);
  });
});
//Cierra al hacer clic fuera del contenido del dialogo 
[dialogAddExpense, dialogViewExpense, dialogViewFriend].forEach(dialog => {
  if (!dialog) return;
  dialog.addEventListener("click", (e) => {
    if (e.target === dialog) {
      closeDialog(dialog);
    }
  });
});
//cierra al pulsar la tecla esc
document.addEventListener("keydown", (e) => {
  if (e.key !== "Escape") return;
  [dialogAddExpense, dialogViewExpense, dialogViewFriend].forEach(dialog => {
    if (dialog && !dialog.hidden) closeDialog(dialog);
  });
});

// AÑADIR GASTO 
//logica del boton principal añador gasto
if (addExpenseButton && dialogAddExpense) {
  addExpenseButton.addEventListener("click", () => {
    // abrir en modo crear (no editar)
    editingExpenseId = null;
    const nameInput = document.getElementById("add-expense-name");
    const dateInput = document.getElementById("add-expense-date");
    const amountInput = document.getElementById("add-expense-amount");
    if (nameInput) nameInput.value = "";
    if (dateInput) dateInput.value = "";
    if (amountInput) amountInput.value = "";
    const err = dialogAddExpense.querySelector('.form-error');
    if (err) err.textContent = '';
    if (addExpenseDialogTitle) addExpenseDialogTitle.textContent = "Añadir gasto";
    if (addExpenseAcceptBtn) addExpenseAcceptBtn.textContent = "Aceptar";
    openDialog(dialogAddExpense);
  });

  const nameInput = document.getElementById("add-expense-name");
  const dateInput = document.getElementById("add-expense-date");
  const amountInput = document.getElementById("add-expense-amount");
  const acceptBtn = dialogAddExpense.querySelector(".accept");
  const cancelBtn = dialogAddExpense.querySelector(".cancel");
  //boton aceptar del popup añadir gasto
  acceptBtn.addEventListener("click", () => {
    
    const title = (nameInput.value || "").trim();
    const date = (dateInput.value || "").trim();
    const rawAmount = amountInput.value.trim(); 
    const total = Number(rawAmount);

    if (!title || !date || rawAmount === "" || !Number.isFinite(total) || total < 0) {
        alert("Rellena nombre, fecha y un importe válido.");
        return;
    }

    // flag local para saber si venimos en modo edición
    const wasEditing = editingExpenseId != null;

    if (wasEditing) {
      // modo edición: actualizar el gasto existente
      const exp = expenses.find(e => e.id === editingExpenseId);
      if (exp) {
        exp.title = title;
        exp.date = date;
        exp.total = total;
      }
      editingExpenseId = null;
    } else {
      // modo creación: Generar nuevo id (maximo axtual+1)
      const newId = expenses.length === 0
        ? 1
        : Math.max(...expenses.map(e => e.id)) + 1;
      //añade nuevo gasto al array principal 
      expenses.push({
        id: newId,
        title,
        date,
        total,
        participants: [] //Empieza sin participantes
      });
    }
    //limpia los campos del formulario
    nameInput.value = "";
    dateInput.value = "";
    amountInput.value = "";
    //ACtualiza todas las vistas
    applyExpenseFilters();
    applyFriendFilters();
    recalcFriendBalances();
    renderExpenses();
    renderFriends();
    renderSummary();

    try {
      showToast(wasEditing ? 'Gasto editado' : 'Gasto añadido', 3000);
     } catch (e) {
       //ignorar
     }
    closeDialog(dialogAddExpense);
  });
  //boton cancelar solo cierra
  cancelBtn.addEventListener("click", () => {
    closeDialog(dialogAddExpense);
  });
}

// INICIALIZACIÓN 
//llamadas iniciales para que la pagina cargue los datos al abrirse
applyExpenseFilters();
applyFriendFilters();
recalcFriendBalances();
renderExpenses();
renderFriends();
renderSummary();


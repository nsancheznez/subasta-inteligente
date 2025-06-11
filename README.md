# 🧾 Subasta Smart Contract

Este contrato inteligente implementa una subasta con extensión automática del tiempo, devolución de excedentes y verificación de ganador. Desarrollado en Solidity para Ethereum o redes compatibles con EVM.

---

## 📦 Contenido

- [Variables](#-variables)
- [Funciones](#-funciones)
- [Eventos](#-eventos)

---

## 🔧 Variables

### Públicas

- `address public owner`  
  Dirección del creador del contrato.

- `uint public auctionEndTime`  
  Marca de tiempo (timestamp) en la que finaliza la subasta.

- `uint public highestBid`  
  Oferta actual más alta.

- `address public highestBidder`  
  Dirección del postor con la oferta más alta.

- `bool public auctionEnded`  
  Indica si la subasta fue finalizada.

- `mapping(address => uint) public bids`  
  Almacena las ofertas activas de cada postor.

- `mapping(address => uint[]) public previousOffers`  
  Historial de ofertas anteriores por postor.

- `mapping(address => uint) public pendingReturns`  
  Montos que los postores pueden retirar.

- `address[] public bidders`  
  Lista de todas las direcciones que participaron.

### Constantes

- `uint constant EXTENSION_TIME = 10 minutes`  
  Tiempo adicional si una oferta ocurre cerca del fin.

- `uint constant COMMISSION_PERCENT = 2`  
  Comisión (%) para el owner sobre la oferta ganadora.

---

## ⚙️ Funciones

### Constructor

```solidity
constructor(uint _durationMinutes) payable
````

Inicializa la subasta con duración en minutos. La primera oferta debe enviarse con `msg.value` por parte del `owner`.

---

### Funciones principales

* `function bid() external payable`
  Realiza una oferta. Debe superar al menos un 5% la oferta más alta actual. Guarda historial y extiende el tiempo si es necesario.

* `function withdrawExcess() external`
  Permite al usuario retirar ofertas anteriores que hayan sido superadas.

* `function endAuction() external onlyAfterEnd onlyOwner`
  Finaliza la subasta, envía fondos al owner y reembolsa al resto.

---

### Consultas

* `function getWinner() external view returns (address, uint)`
  Devuelve el postor actual ganador y su oferta.

* `function getTime() external view returns(uint)`
  Retorna el tiempo restante en segundos.

* `function getAllOffers() external view returns (address[] memory, uint[] memory)`
  Retorna todos los postores y sus ofertas actuales.

* `function getPreviousOffers(address bidder) external view returns (uint[] memory)`
  Devuelve el historial de ofertas previas para una dirección específica.

---

### Manejo de ETH directo

* `receive() external payable`
  Si se intenta enviar ETH sin interactuar con funciones, revierte la transacción con un error.

---

## 📢 Eventos

* `event NewBid(address indexed bidder, uint amount)`
  Emitido cuando se realiza una nueva oferta válida.

* `event AuctionExtended(uint newEndTime)`
  Emitido cuando se extiende el tiempo de la subasta.

* `event Withdraw(address indexed user, uint amount)`
  Emitido cuando un usuario retira ETH de ofertas anteriores.

* `event AuctionEnded(address winner, uint amount)`
  Emitido al finalizar exitosamente la subasta.

---

## 🛡️ Modificadores

* `onlyOwner`
  Restringe el uso de funciones al creador del contrato.

* `onlyWhileOpen`
  Asegura que la subasta esté activa.

* `onlyAfterEnd`
  Asegura que la subasta haya terminado.

---

> 💡 Desarrollado con Solidity ^0.8.20

```
```

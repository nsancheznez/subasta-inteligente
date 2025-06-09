# Subasta en Solidity

## 1. Descripción funcional del contrato

Este contrato implementa una subasta pública en la cual los usuarios pueden realizar ofertas durante un tiempo limitado. La subasta se inicializa con una duración dada y finaliza una vez transcurrido ese tiempo. El mejor postor al finalizar la subasta es considerado el ganador. Se permite retirar las ofertas previas a quienes hayan sido superados.

## 2. Variables de estado utilizadas

- `address payable public beneficiary`: dirección del subastador.
- `uint public auctionEndTime`: tiempo de finalización de la subasta.
- `address public highestBidder`: dirección del mejor postor actual.
- `uint public highestBid`: oferta más alta actual.
- `mapping(address => uint) public pendingReturns`: mapeo de fondos a devolver.
- `bool public ended`: indica si la subasta finalizó.
- `uint public commission`: comisión del 2% para el propietario.
- `uint public duration`: duración de la subasta en minutos.
- `Offer[] public offers`: arreglo de ofertas realizadas.

## 3. Funciones principales

- `constructor(uint _durationMinutes)`: inicializa el contrato con duración en minutos.
- `bid() public payable`: permite realizar una oferta, debe superar la anterior en al menos un 5%.
- `withdrawPartialRefund() public`: permite retirar los fondos ofrecidos si el usuario no es el mejor postor.
- `endAuction() public`: finaliza la subasta, transfiere los fondos al beneficiario y distribuye reembolsos.
- `getAllOffers() public view returns (Offer[] memory)`: retorna todas las ofertas registradas.

## 4. Lógica de actualización de la mejor oferta

Cada vez que se llama a `bid()`, se verifica que el nuevo monto ofrecido supere en al menos un 5% a la oferta actual. Si es así, se actualiza `highestBid` y `highestBidder`. La oferta anterior se registra en `pendingReturns` para que el oferente pueda retirarla luego.

## 5. Condiciones de finalización de la subasta

La subasta puede finalizarse manualmente mediante la función `endAuction()` siempre que haya pasado el tiempo de duración definido en el constructor. Solo puede finalizarse una vez.

## 6. Gestión del envío de fondos

- El mejor postor no puede retirar su oferta.
- Al finalizar la subasta, se transfiere el 98% del monto al beneficiario (`beneficiary.transfer(...)`) y el 2% queda como comisión.
- Las demás ofertas quedan disponibles para ser retiradas por los respectivos usuarios mediante `withdrawPartialRefund()`.

## 7. Validaciones realizadas

- No se permite ofertar si la subasta terminó.
- La oferta debe ser mayor en al menos un 5% respecto a la anterior.
- No se puede finalizar dos veces la subasta.
- Solo pueden retirarse fondos que no correspondan al mejor postor.


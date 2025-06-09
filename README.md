# Subasta Inteligente en Solidity

Este proyecto implementa un contrato inteligente para una subasta dinámica con las siguientes características:

- Ofertas mínimas con incremento del 5% sobre la mejor.
- Reembolsos automáticos a oferentes no ganadores.
- Extensión automática del tiempo si se ofertan en los últimos 10 minutos.
- Comisión del 2% para el creador de la subasta.

## 🛠 Funcionalidades principales

- `bid()`: Realiza una oferta. Se exige mínimo un 5% más que la oferta máxima actual.
- `getAllOffers()`: Devuelve todos los oferentes y sus montos.
- `endAuction()`: Finaliza la subasta, transfiere fondos y emite evento.
- `withdrawPartialRefund()`: Permite retirar fondos anteriores si se hace una nueva oferta.
- Eventos emitidos: `NewBid`, `AuctionExtended`, `AuctionEnded`.

## ⚙️ Cómo desplegar y probar en Remix

1. Abrí [Remix IDE](https://remix.ethereum.org/).
2. Pegá el código del contrato en un nuevo archivo (por ejemplo: `Subasta.sol`).
3. Compilá usando Solidity `^0.8.20`.
4. En el panel **Deploy & Run**, elegí un ambiente (p. ej. JavaScript VM).
5. En el constructor, pasá la duración en minutos (por ejemplo, `5`).
6. Hacé clic en **Deploy**.
7. Probá las funciones:
   - Enviar ETH a `bid()` desde diferentes cuentas.
   - Llamar `getAllOffers()` para ver las ofertas.
   - Esperar o forzar que termine el tiempo y llamar `endAuction()`.

## 🔒 Requisitos y seguridad

- Solo se permite una oferta por cuenta activa.
- Se evitan reentradas usando lógica defensiva en los reembolsos.
- Se previene la sobreescritura accidental del mejor postor.

## 📜 Licencia

Este contrato se publica bajo la licencia MIT.

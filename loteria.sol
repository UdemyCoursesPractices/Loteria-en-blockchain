// SPDX-License_Identifier: MIT
pragma solidity >0.4.4 <0.9.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract loteria {
    //instancia del ocntrato Token
    ERC20Basic private token;

    //direccines
    address public owner;
    address public contrato;

    // Numero de tokens a crear
    uint public tokens_Creados = 10000;

    constructor () public {
        token = new ERC20Basic(tokens_Creados);
        owner = msg.sender;
        
        //con esta sentencia nos referimos al propio contrato.
        contrato = address(this);
    }

    // --------------------------------TOKEN----------------------------------------
    // Establacer el precio de los tokens en ethers
    function PrecioTokens(uint _numTokens) internal pure returns (uint){
        return _numTokens*(1 ether);
    }

    //generar mas Tokens por la loteria.
    function generaTokens(uint _num) public UnicamenteFor(msg.sender){
        token.increaseTotalSupply(_num);
    }
    //Modifica las funciones para que solo sean ejecutables por el owner del contrato.
    modifier UnicamenteFor(address _direccion) {
        require (_direccion == owner, "No tienes permido para ejecutar esta funcion");
        _;
    }

    // Comprar tokens para comprar boletos para la loteria
    function CompraTokens(uint _numTokens) public payable {
        //Calcular el coste de los tokens
        uint coste = PrecioTokens(_numTokens);
        //Se requiere que el valor de ethers pagados sea equivalente al coste.
        require(msg.value >= coste, "Compra menos Tokens o paga con mas Ethers");
        // me tienen que regresar el vuelto si pague con mas de lo debido.
        uint returnValue= msg.value - coste;
        //trasferencia de diferencia.
        //msg.sender.transfer(returnValue);
        //obtener el balance de toknes del cntrato
        uint Balance = tokensDisponibles();
        //filtro para evaluar los tokens a comparr con los tokens disponibles
        require(_numTokens <= Balance, "Compra un numero de Tokens adecuado" ); 
        //Transferencia de Tokens al comprador
        token.transfer(msg.sender, _numTokens);
    }

    function tokensDisponibles() public returns(uint){
        return token.balanceOf(contrato);

    }






















}
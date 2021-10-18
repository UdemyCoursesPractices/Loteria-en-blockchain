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

    event ComprandoTokens(uint, address);

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
        //emitir la compra
        emit ComprandoTokens(_numTokens, msg.sender);
    }

    function tokensDisponibles() public returns(uint){
        return token.balanceOf(contrato);
    }
    
    //Obtener el balance de tokens acumulados en el bote.
    function Bote() public view returns (uint) {
        return token.balanceOf(owner);
    }

    //Funcion para ver la cantidad de tokens tiene una wallet
    function MisTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }


    // ---------------------------LOTERIA-----------------------------------

    //Precio del boleto.
    uint public PrecioBoleto = 5;
    //Relacion entre la persona que compra los boletos y los numeros del boleto.
    mapping (address => uint []) idPersona_boletos;
    // Relacion necesario para identificar al ganador.
    mapping (uint => address) ADN_boleto;
    //Numero aleatorio, para generar voletos.
    uint randNonce = 0;
    //Boletos generados 
    uint [] boletos_comprados;
    //eventos
    event boleto_comprado(uint,address); //Evento cuando se compra un voleto
    event boleto_ganador(uint);  //Evento del ganador
    event tokens_devueltos(uint, address);

    //funion para comprar boletos de loteria
    function CompraBoletos(uint _boletos) public {
        //Precio total de los boletos a compra
        uint precio_total = _boletos * PrecioBoleto;
        //Filtrado de los tokens a pagar
        require(precio_total <= MisTokens(), "Necesitas comprar mas mas tokens");
        //Transferencia de tokens al owner -> bote/premio
        token.transferencia_loteria(msg.sender,owner, precio_total);


        /*Lo que esto hace es tomar la marca de tiempo, block.timestamp, el msg.sener y un nonce
        (numero que solo se utiliza una vez, para que no ejecutemos dos veces la misma funcion de hash con los mismos parametros)
        en incremento.
        Luego se utiliza keccack256 para convertir estas entradas a un hash aleatorio,
        convertir ese hash a un uint y luego utiliamos %10000 para tomar los ultimos 4 digitos.
        nos dara un valor aleatorio entre 0 - 9999.

        */
        for (uint i = 0; i< _boletos; i++){
            uint random =uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
            randNonce++;
            //almacenamos los datos de los boletos.
            idPersona_boletos[msg.sender].push(random);
            boletos_comprados.push(random);
            // asignacion del adn del boleto para tener un ganador
            ADN_boleto[random] = msg.sender;
            //Emision del evento
            emit boleto_comprado(random,msg.sender);

        }

    }
    //visualizar el num de boletos de una persona
    function TusBoletos() public view returns(uint [] memory){
        return idPersona_boletos[msg.sender];
    }
    //funcion para encontrar un ganador y entregable los tokens
    function ganador() public UnicamenteFor(msg.sender){
        //Debe haber boletos comprados para generar un ganador
        require(boletos_comprados.length > 0, "No hay boletos comprados");
        // Declaracion de la longitud del array
        uint longitud = boletos_comprados.length;
        //Aleatoriamente elijo un numero entre 0 - longitud
        uint posicion_array = uint(uint(keccak256(abi.encodePacked(block.timestamp)))%longitud);
        //seleccion del numero aleatorio mediante la posicion del array aleatorio
        uint eleccion = boletos_comprados[posicion_array];
        //emision del evento del ganador
        emit boleto_ganador(eleccion);
        //Recuperar la direccion del ganador
        address direccion_ganador = ADN_boleto[eleccion];
        token.transferencia_loteria(msg.sender, direccion_ganador, Bote());

    }

    //Devolucion de los tokens
    function DevolverTokens(uint _numTokens) public payable {
        //El numero de tokens a devolver debe ser mayor a 0
        require (_numTokens > 0, "Necesitas devolver un numero positivo de tokens");
        //el usuario/cliente debe tener los tokens que desea devolver
        require(_numTokens <= MisTokens(), "No tiene los tokens que deseas devolver");
        //Devolucion
        //1. El cliente devuelva los tokens
        //2. La loteria paga los tokens devueltos en ethers
        msg.sender.transfer(PrecioTokens(_numTokens));
        //Emision del evento
        emit tokens_devueltos(_numTokens, msg.sender);
    }



}
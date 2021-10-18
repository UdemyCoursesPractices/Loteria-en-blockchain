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
    function precioTokens(uint _numTokens) internal pure returns (uint){
        return _numTokens*(1 ether);
    }


}
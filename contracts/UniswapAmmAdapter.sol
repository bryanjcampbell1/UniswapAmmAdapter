// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;
pragma experimental "ABIEncoderV2";

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

/**
 * @title UniswapAmmAdapter
 * @author Bryan Campbell
 *
 * Uniswap V2 Adapter for adding liquidity through Set Protocol
 */
contract UniswapAmmAdapter {

    /* ============ State Variables ============ */
    
    // Address of Uniswap V2 Router02 contract
    IUniswapV2Router02 public immutable router;
    IUniswapV2Factory  public immutable factory;

    /* ============ Constructor ============ */

    /**
     * Set state variables
     *
     * @param _router       Address of Uniswap V2 Router02 contract
     * @param _factory      Address of Uniswap V2 Factory contract
     */
    constructor(
        address _router,
        address _factory
    )
        public
    {
        router  = IUniswapV2Router02(_router);
        factory = IUniswapV2Factory(_factory);
    }

    /* ============ External Getter Functions ============ */

    function getProvideLiquidityCalldata(
        address _pool,
        address[] calldata _components,
        uint256[] calldata _maxTokensIn,
        uint256 _minLiquidity //_minLiquidity can refer to the total supply of the pool tokens. 
    )
        external
        view
        returns (address, uint256, bytes memory)
    {   

        require(factory.getPair(_components[0],_components[1]) != 0x0000000000000000000000000000000000000000 ,"No pool found at address");
        require(factory.getPair(_components[0],_components[1]) == _pool, "Pool does not match token pair");

        bytes memory callData = abi.encodeWithSignature(
            "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)", 
            _components[0],     // address tokenA
            _components[1],     // address tokenB
            _maxTokensIn[0],    // uint amountADesired
            _maxTokensIn[1],    // uint amountBDesired
            _minLiquidity, //?     // uint amountAMin  
            _minLiquidity, //?     // uint amountBMin
            _pool,              // address to  --> is to == pool anywhere else?
            block.timestamp     // deadline
        );

        return (address(router), 0, callData);

    }    


    function getRemoveLiquidityCalldata(
        address _pool,
        address[] calldata _components,
        uint256[] calldata _minTokensOut,
        uint256 _liquidity
    ) 
    external 
    view 
    returns (address, uint256, bytes memory)
    {
        
        require(factory.getPair(_components[0],_components[1]) != 0x0000000000000000000000000000000000000000, "No pool found at address");
        require(factory.getPair(_components[0],_components[1]) == _pool, "Pool does not match token pair");

        bytes memory callData = abi.encodeWithSignature(
            "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)",
            _components[0],     //address tokenA,
            _components[1],     //address tokenB,
            _liquidity,         //uint liquidity
            _minTokensOut[0],  //uint amountAMin
            _minTokensOut[1],  //uint amountBMin
            _pool,                //address to
            block.timestamp     //uint deadline
        );

        return (address(router), 0, callData);
    }



    function getProvideLiquiditySingleAssetCalldata(
        address _pool,
        address _component,
        uint256 _maxTokenIn,
        uint256 _minLiquidity
    ) 
        external 
        view 
        returns (address, uint256, bytes memory)
    {
        require(false, "Uniswap pools require a token pair");
    }


    function getRemoveLiquiditySingleAssetCalldata(
        address _pool,
        address _component,
        uint256 _minTokenOut,
        uint256 _liquidity
    ) 
    external 
    view 
    returns (address, uint256, bytes memory)
    {
        require(false, "Uniswap pools require a token pair");

    }


    /**
     * Returns the address to approve source tokens to for trading. This is the Uniswap router address
     *
     * @return address             Address of the contract to approve tokens to
     */

    function getSpenderAddress(address _pool)  //_pool just included to match set protocol's definition/interface
        external
        view
        returns (address)
    {
        return address(router);
    }

    function isValidPool(address _pool) 
        external 
        view 
        returns(bool)
    {
        for(uint i = 0; i< factory.allPairsLength(); i++){
            if( factory.allPairs(i) == _pool){
                return(true);
            }
        }

        return(false);
    }

}


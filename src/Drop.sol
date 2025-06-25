// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {ERC721, ERC165, ERC721TokenReceiver, ERC721Metadata} from "./interfaces/IDrop.sol";

contract Drop is ERC721, ERC165, ERC721TokenReceiver, ERC721Metadata {
    error Drop__InvalidAddress();
    error Drop__ErrorInOwner();

    string public _name;
    string public _symbol;

    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;
    mapping(uint256 tokenId => address) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool))
        private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        if (_owner == address(0)) {
            revert Drop__InvalidAddress();
        }

        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = _owners[_tokenId];

        if (tokenOwner == address(0)) {
            revert Drop__ErrorInOwner();
        }

        return tokenOwner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        address tokenOwner = ownerOf(_tokenId);

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, _tokenId.toString())
                : "";
    }

    function _baseURI() public returns (string memory) {
        return "";
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {ERC721, ERC165, ERC721TokenReceiver, ERC721Metadata} from "./interfaces/IDrop.sol";
import {Strings} from "./utils/Strings.sol";

contract Drop is ERC721, ERC165, ERC721TokenReceiver, ERC721Metadata {
    error Drop__InvalidAddress();
    error Drop__ErrorInOwner();
    error Drop__Unauthorized();
    error Drop__NotERC721Receiver();
    error Drop__AlreadyOwner();
    error Drop__InvalidToken();
    error Drop__SelfApproval();

    string public _name;
    string public _symbol;

    uint256 private _tokenIdCounter = 1;

    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;
    mapping(uint256 tokenId => address) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;
    mapping(uint256 tokenId => string) private _tokenURIs;

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

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
        if (!_operatorApprovals[msg.sender][_to]) {
            revert Drop__Unauthorized();
        }

        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal virtual {
        _transfer(_from, _to, _tokenId);

        if (!_checkOnERC721Received(_from, _to, _tokenId, _data)) {
            revert Drop__NotERC721Receiver();
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        if (!_operatorApprovals[msg.sender][_to]) {
            revert Drop__Unauthorized();
        }

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public override {
        address owner = ownerOf(_tokenId);

        if (_approved == owner) {
            revert Drop__AlreadyOwner();
        }

        if (msg.sender != owner || !isApprovedForAll(owner, msg.sender)) {
            revert Drop__Unauthorized();
        }

        _tokenApprovals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function getApproved(uint256 _tokenId) public view override returns (address) {
        if (_owners[_tokenId] == address(0)) {
            revert Drop__InvalidToken();
        }

        return _tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public override {
        if (_operator == msg.sender) {
            revert Drop__SelfApproval();
        }

        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function mint(address to, string memory uri) public {
        uint256 id = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[id] = to;
        _balances[to] += 1;
        _tokenURIs[id] = uri;

        emit Transfer(address(0), to, id);
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        address tokenOwner = ownerOf(_tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, _tokenId.toString()) : "";

        return _tokenURIs[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        if (ownerOf(_tokenId) != _from) {
            revert Drop__Unauthorized();
        }

        if (_to == address(0)) {
            revert Drop__InvalidAddress();
        }

        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        delete _tokenApprovals[_tokenId];
        emit Transfer(_from, _to, _tokenId);
    }

    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data)
        internal
        view
        returns (bool)
    {
        if (_to.code.length > 0) {
            try ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 retval) {
                return retval == ERC721TokenReceiver.onERC721Received.selector;
            } catch {
                return false;
            }
        }
    }

    function _baseURI() public returns (string memory) {
        return "";
    }
}

//SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Blog {
    string public name;
    address public owner;

    using Counters for Counters.Counter;
    Counters.Counter private _postIds;

    struct Post {
        uint256 id;
        string title;
        string content;
        bool Published;
    }

    mapping(uint256 => Post) private idToPosts;
    mapping(string => Post) private hashToPost;

    event PostCreated(uint256 id, string title, string hash);
    event PostUpdated(uint256 id, string title, string hash, bool Published);

    constructor(string memory _name) {
        console.log("Deploying contract with name: ", _name);
        name = _name;
        owner = msg.sender;
    }

    function updateName(string memory _name) public {
        name = _name;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function fectchPost(string memory hash) public view returns (Post memory) {
        return hashToPost[hash];
    }

    function createPost(string memory title, string memory hash)
        public
        onlyOwner
    {
        _postIds.increment();
        uint256 postId = _postIds.current();
        Post storage post = idToPosts[postId];
        post.id = postId;
        post.title = title;
        post.Published = true;
        post.content = hash;
        hashToPost[hash] = post;
        emit PostCreated(postId, title, hash);
    }

    function updatePost(
        uint256 id,
        string memory title,
        string memory hash,
        bool published
    ) public onlyOwner {
        Post storage post = idToPosts[id];
        post.title = title;
        post.content = hash;
        post.Published = published;
        idToPosts[id] = post;
        hashToPost[hash] = post;
        emit PostUpdated(id, title, hash, published);
    }

    function fetchPosts() public view returns (Post[] memory) {
        uint256 itemCount = _postIds.current();
        uint256 currentIndex = 0;

        Post[] memory posts = new Post[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            uint256 currentId = i + 1;
            Post storage currentItem = idToPosts[currentId];
            posts[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return posts;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { DeployBox } from "../script/DeployBox.s.sol";
import { UpgradeBox } from "../script/UpgradeBox.s.sol";
import { BoxV1 } from "../src/BoxV1.sol";
import { BoxV2 } from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox deployer;
    UpgradeBox upgrader;
    address public OWNER = makeAddr("owner");

    // address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        // proxy = BoxV1(deployer.run()); // right now, points to boxV1
    }

    function testBoxWorks() public {
        address proxyAddress = deployer.deployBox();
        uint256 expectedValue = 1;
        assertEq(expectedValue, BoxV1(proxyAddress).version());
        }
    function testProxyStartsAsBoxV1() public {
        address proxyAddress = deployer.deployBox();
        uint256 expectedValue = 7;
        vm.expectRevert();
        BoxV2(proxyAddress).setNumber(expectedValue);
    }

    function testUpgrades() public {
        address proxyAddress = deployer.deployBox();
        BoxV2 box2 = new BoxV2();
        
        upgrader.upgradeBox(proxyAddress, address(box2));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxyAddress).version());

        BoxV2(proxyAddress).setNumber(7);
        assertEq(7, BoxV2(proxyAddress).getNumber());
    }
}
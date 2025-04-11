<h2 align="center">About Me </h2>

```solidity
contract WuliLiuyue {
    function contact() external pure returns (string memory) {
        return "wuliLiuyue";
    }

    function life() external pure returns (string[] memory, uint256) {
        string[] memory langs = new string[](2);
        langs[0] = "Chinese";
        langs[1] = "English";
        uint256 age = 18;
        return (langs, age);
    }

    function coding() external pure returns (
        string[][] memory, 
        string[] memory, 
        string[] memory
    ) {
        string[][] memory langs = new string[][](3);
        
        langs ;
        langs[0][0] = "js";
        langs[0][1] = "dart";
        
        langs ;
        langs[1][0] = "java";
        langs[1][1] = "python";
        
        langs ;
        langs[2][0] = "go";
        langs[2][1] = "solidity";
        
        string[] memory specialities = new string[](3);
        specialities[0] = "web/app fullstack engineering";
        specialities[1] = "ai agent";
        specialities[2] = "smart contract";
        
        string[] memory environnement = new string[](1);
        environnement[0] = "cursor";
        
        return (langs, specialities, environnement);
    }
}
```
<h2 align="center">Skills </h2>

<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=js,dart,java,python,go,solidity" />
  </a>
</p>

<p align="center">
    <img alt="" src="https://github-readme-stats.vercel.app/api?username=wuliLiuyue&count_private=true&theme=tokyonight&show_icons=true">
</p>

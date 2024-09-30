---
title: 基于C++的业余无线电呼号查询工具
tags:
  - 业余无线电
  - C++
categories: 业余无线电
abbrlink: 378c08ae
date: 2024-09-30 22:20:43
---
## 前言

自从接触业余无线电后，就会对见到的每个呼号都产生好奇心，总想查一查这些HAM呼号的QTH。网络上的QTH查询工具需要呼号所有者自行上传位置，而没上传的自然就查不到，于是萌生了自己写一个查询工具的想法，查到具体省份即可。

该工具依据*业余无线电台呼号管理办法*，基于C++所写，为初学练手项目，如有不足，恳请批评指正：[Goal75KG/CallSignQuery](https://github.com/Goal75KG/CallSignQuery)。

## 功能

- 根据呼号解析出国家信息（暂时只能解析中国）
- 查询电台种类（个人业余电台、信标台、卫星电台等）
- 确定呼号所属省份
- 处理特殊情况的电台种类

## 示例

输入呼号：`BA8MAA`

输出结果：

```
呼号: BA8MAA
国家: 中国
电台种类: 个人业余电台（一级）
省份: 贵州
```

## 实现过程

**映射呼号每部分规则**

```c++
// 加载国家前缀规则
std::map<std::string, std::string> loadCountryPrefixRules() {
    std::map<std::string, std::string> countryPrefixRules;
    countryPrefixRules["B"] = "中国";
    return countryPrefixRules;
    
// 加载电台种类规则
std::map<char, std::string> loadStationTypeRules() {
    std::map<char, std::string> stationTypeRules;
    stationTypeRules['A'] = "个人业余电台（一级）";
    stationTypeRules['D'] = "个人业余电台（二级）";
    stationTypeRules['E'] = "个人业余电台（二级）";
    stationTypeRules['G'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['H'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['I'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['J'] = "业余信标台";
    stationTypeRules['L'] = "外籍及香港、澳门、台湾地区人员在中国内地设置的业余电台";
    stationTypeRules['R'] = "业余中继台";
    stationTypeRules['T'] = "特设业余电台";
    stationTypeRules['Y'] = "集体业余电台";
    return stationTypeRules;
}
    
// 加载大区和省份范围规则
std::map<char, std::map<std::string, std::pair<std::string, std::string> > > loadRegionProvinceRules() {
    std::map<char, std::map<std::string, std::pair<std::string, std::string> > > regionProvinceRules;

    // 第1区：北京
    regionProvinceRules['1'] = {
        {"北京", {"AA", "XZZ"}}
    };

    // 第2区：黑龙江、辽宁、吉林
    regionProvinceRules['2'] = {
        {"黑龙江", {"AA", "HZZ"}},
        {"吉林", {"IA", "PZZ"}},
        {"辽宁", {"QA", "XZZ"}}
    };

    // 第3区：河北、内蒙古、山西、天津
    regionProvinceRules['3'] = {
        {"天津", {"AA", "FZZ"}},
        {"内蒙古", {"GA", "LZZ"}},
        {"河北", {"MA", "RZZ"}},
        {"山西", {"SA", "XZZ"}}
    };

    // 第4区：山东、江苏、上海
    regionProvinceRules['4'] = {
        {"上海", {"AA", "HZZ"}},
        {"山东", {"IA", "PZZ"}},
        {"江苏", {"QA", "XZZ"}}
    };

    // 第5区：浙江、江西、福建
    regionProvinceRules['5'] = {
        {"浙江", {"AA", "HZZ"}},
        {"江西", {"IA", "PZZ"}},
        {"福建", {"QA", "XZZ"}}
    };

    // 第6区：河南、湖北、安徽
    regionProvinceRules['6'] = {
        {"安徽", {"AA", "HZZ"}},
        {"河南", {"IA", "PZZ"}},
        {"湖北", {"QA", "XZZ"}}
    };

    // 第7区：湖南、广东、广西、海南
    regionProvinceRules['7'] = {
        {"湖南", {"AA", "HZZ"}},
        {"广东", {"IA", "PZZ"}},
        {"广西", {"QA", "XZZ"}},
        {"海南", {"YA", "ZZZ"}}
    };

    // 第8区：四川、贵州、云南、重庆
    regionProvinceRules['8'] = {
        {"四川", {"AA", "FZZ"}},
        {"重庆", {"GA", "LZZ"}},
        {"贵州", {"MA", "RZZ"}},
        {"云南", {"SA", "XZZ"}}
    };

    // 第9区：陕西、甘肃、宁夏、青海
    regionProvinceRules['9'] = {
        {"陕西", {"AA", "FZZ"}},
        {"甘肃", {"GA", "LZZ"}},
        {"宁夏", {"MA", "RZZ"}},
        {"青海", {"SA", "XZZ"}}
    };

    // 第0区：新疆、西藏
    regionProvinceRules['0'] = {
        {"新疆", {"AA", "FZZ"}},
        {"西藏", {"GA", "LZZ"}}
    };

    return regionProvinceRules;
}
```

**判断对应后缀是否在范围内**

```c++
bool isWithinRange(const std::string &suffix, const std::string &rangeStart, const std::string &rangeEnd) {
    return suffix >= rangeStart && suffix <= rangeEnd;
}
```

**呼号匹配**

```c++
void queryCallSign(const std::string &callSign) {
    // 加载各类规则
    auto countryRules = loadCountryPrefixRules();
    auto stationTypeRules = loadStationTypeRules();
    auto regionProvinceRules = loadRegionProvinceRules();

    // 确保呼号至少有5位
    if (callSign.length() < 5) {
        std::cout << "呼号格式不正确" << std::endl;
        return;
    }

    // 解析国家前缀
    std::string country = countryRules[callSign.substr(0, 1)];

    // 解析电台种类
    char stationType = callSign[1];
    std::string station = stationTypeRules[stationType];

    // 解析地区分区
    char region = callSign[2];

    // 解析后缀
    std::string suffix = callSign.substr(3, 2); // 假设后缀长度为2位

    // 查找该地区的省份范围
    std::string provinceName = "未知省份";
    if (regionProvinceRules.find(region) != regionProvinceRules.end()) {
        for (const auto &province: regionProvinceRules[region]) {
            if (isWithinRange(suffix, province.second.first, province.second.second)) {
                provinceName = province.first;
                break;
            }
        }
    }
```

**处理特殊情况（业余信标台、卫星业余电台、特设业余电台）**

```c++
if (stationType == 'J') {
        char suffix1 = callSign[3];
        if (suffix1 == 'H' || suffix1 == 'V' || suffix1 == 'U') {
            station = "HF、VHF、UHV频段信标台";
        } else if (suffix1 == 'D') {
            station = "业余无线电测向专用信标台";
        } else if (suffix1 == 'S' && region == '1') {
            station = "卫星业余电台";
        } else if (suffix1 == 'T') {
            station = "特设业余电台";
        }
    }
```

**结果输出**

```c++
    if (!country.empty() && !station.empty() && provinceName != "未知省份") {
        std::cout << "呼号: " << callSign << std::endl;
        std::cout << "国家: " << country << std::endl;
        std::cout << "电台种类: " << station << std::endl;
        std::cout << "省份: " << provinceName << std::endl;
    } else {
        std::cout << "未找到呼号对应的信息" << std::endl;
    }
}
```

**主程序**

```c++
int main() {
    std::string callSign;
    std::cout << "请输入要查询的呼号: ";
    std::cin >> callSign;
    std::cout << "\n查询结果如下:\n" << std::endl;

    // 查询呼号信息
    queryCallSign(callSign);
    system("pause");
    return 0;
}
```

## 源代码

```c++
#include <iostream>
#include <map>
#include <string>

// 加载国家前缀规则
std::map<std::string, std::string> loadCountryPrefixRules() {
    std::map<std::string, std::string> countryPrefixRules;
    countryPrefixRules["B"] = "中国";
    return countryPrefixRules;
}

// 加载电台种类规则
std::map<char, std::string> loadStationTypeRules() {
    std::map<char, std::string> stationTypeRules;
    stationTypeRules['A'] = "个人业余电台（一级）";
    stationTypeRules['D'] = "个人业余电台（二级）";
    stationTypeRules['E'] = "个人业余电台（二级）";
    stationTypeRules['G'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['H'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['I'] = "个人业余电台（三级、四级、五级（收信台））";
    stationTypeRules['J'] = "业余信标台";
    stationTypeRules['L'] = "外籍及香港、澳门、台湾地区人员在中国内地设置的业余电台";
    stationTypeRules['R'] = "业余中继台";
    stationTypeRules['T'] = "特设业余电台";
    stationTypeRules['Y'] = "集体业余电台";
    return stationTypeRules;
}

// 加载大区和省份范围规则
std::map<char, std::map<std::string, std::pair<std::string, std::string> > > loadRegionProvinceRules() {
    std::map<char, std::map<std::string, std::pair<std::string, std::string> > > regionProvinceRules;

    // 第1区：北京
    regionProvinceRules['1'] = {
        {"北京", {"AA", "XZZ"}}
    };

    // 第2区：黑龙江、辽宁、吉林
    regionProvinceRules['2'] = {
        {"黑龙江", {"AA", "HZZ"}},
        {"吉林", {"IA", "PZZ"}},
        {"辽宁", {"QA", "XZZ"}}
    };

    // 第3区：河北、内蒙古、山西、天津
    regionProvinceRules['3'] = {
        {"天津", {"AA", "FZZ"}},
        {"内蒙古", {"GA", "LZZ"}},
        {"河北", {"MA", "RZZ"}},
        {"山西", {"SA", "XZZ"}}
    };

    // 第4区：山东、江苏、上海
    regionProvinceRules['4'] = {
        {"上海", {"AA", "HZZ"}},
        {"山东", {"IA", "PZZ"}},
        {"江苏", {"QA", "XZZ"}}
    };

    // 第5区：浙江、江西、福建
    regionProvinceRules['5'] = {
        {"浙江", {"AA", "HZZ"}},
        {"江西", {"IA", "PZZ"}},
        {"福建", {"QA", "XZZ"}}
    };

    // 第6区：河南、湖北、安徽
    regionProvinceRules['6'] = {
        {"安徽", {"AA", "HZZ"}},
        {"河南", {"IA", "PZZ"}},
        {"湖北", {"QA", "XZZ"}}
    };

    // 第7区：湖南、广东、广西、海南
    regionProvinceRules['7'] = {
        {"湖南", {"AA", "HZZ"}},
        {"广东", {"IA", "PZZ"}},
        {"广西", {"QA", "XZZ"}},
        {"海南", {"YA", "ZZZ"}}
    };

    // 第8区：四川、贵州、云南、重庆
    regionProvinceRules['8'] = {
        {"四川", {"AA", "FZZ"}},
        {"重庆", {"GA", "LZZ"}},
        {"贵州", {"MA", "RZZ"}},
        {"云南", {"SA", "XZZ"}}
    };

    // 第9区：陕西、甘肃、宁夏、青海
    regionProvinceRules['9'] = {
        {"陕西", {"AA", "FZZ"}},
        {"甘肃", {"GA", "LZZ"}},
        {"宁夏", {"MA", "RZZ"}},
        {"青海", {"SA", "XZZ"}}
    };

    // 第0区：新疆、西藏
    regionProvinceRules['0'] = {
        {"新疆", {"AA", "FZZ"}},
        {"西藏", {"GA", "LZZ"}}
    };

    return regionProvinceRules;
}

// 判断后缀是否在范围内
bool isWithinRange(const std::string &suffix, const std::string &rangeStart, const std::string &rangeEnd) {
    return suffix >= rangeStart && suffix <= rangeEnd;
}

// 查询呼号
void queryCallSign(const std::string &callSign) {
    // 加载各类规则
    auto countryRules = loadCountryPrefixRules();
    auto stationTypeRules = loadStationTypeRules();
    auto regionProvinceRules = loadRegionProvinceRules();

    // 确保呼号至少有5位
    if (callSign.length() < 5) {
        std::cout << "呼号格式不正确" << std::endl;
        return;
    }

    // 解析国家前缀
    std::string country = countryRules[callSign.substr(0, 1)];

    // 解析电台种类
    char stationType = callSign[1];
    std::string station = stationTypeRules[stationType];

    // 解析地区分区
    char region = callSign[2];

    // 解析后缀
    std::string suffix = callSign.substr(3, 2); // 假设后缀长度为2位

    // 查找该地区的省份范围
    std::string provinceName = "未知省份";
    if (regionProvinceRules.find(region) != regionProvinceRules.end()) {
        for (const auto &province: regionProvinceRules[region]) {
            if (isWithinRange(suffix, province.second.first, province.second.second)) {
                provinceName = province.first;
                break;
            }
        }
    }
    // 处理特殊情况（业余信标台、卫星业余电台、特设业余电台）
    if (stationType == 'J') {
        char suffix1 = callSign[3];
        if (suffix1 == 'H' || suffix1 == 'V' || suffix1 == 'U') {
            station = "HF、VHF、UHV频段信标台";
        } else if (suffix1 == 'D') {
            station = "业余无线电测向专用信标台";
        } else if (suffix1 == 'S' && region == '1') {
            station = "卫星业余电台";
        } else if (suffix1 == 'T') {
            station = "特设业余电台";
        }
    }
    // 输出结果
    if (!country.empty() && !station.empty() && provinceName != "未知省份") {
        std::cout << "呼号: " << callSign << std::endl;
        std::cout << "国家: " << country << std::endl;
        std::cout << "电台种类: " << station << std::endl;
        std::cout << "省份: " << provinceName << std::endl;
    } else {
        std::cout << "未找到呼号对应的信息" << std::endl;
    }
}

int main() {
    std::string callSign;
    std::cout << "请输入要查询的呼号: ";
    std::cin >> callSign;
    std::cout << "\n查询结果如下:\n" << std::endl;

    // 查询呼号信息
    queryCallSign(callSign);
    system("pause");
    return 0;
}
```

## 尾声

**后续计划：**
- [ ] 支持全球呼号
- [ ] 添加GUI

有更多想法？欢迎讨论👏
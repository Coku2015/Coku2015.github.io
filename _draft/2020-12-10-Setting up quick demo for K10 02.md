---
layout: post
title: Kasten K10入门系列 - 快速搭建K8S单节点测试环境（下篇）
tags: Kubernetes
categories: Kubernetes

---

在上一篇，我发布了可用于Kasten K10 demo的虚拟一体机，对于上网不便并且docker和K8S不熟悉的朋友，这个一体机部署非常方便。当然也有不少朋友希望自己动手从一个基础的Linux系统来安装搭建这个环境，今天这一篇帖子我就来给大家详解这个过程。

前提条件

开始安装工作前，本文的工作环境基于大家熟知的CentOS环境，如有朋友希望使用Ubuntu，可以稍加更改部分命令适配Ubuntu即可。
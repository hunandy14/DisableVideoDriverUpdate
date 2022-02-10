禁用 NVIDIA or AMD 顯示卡驅動的自動更新
===

按下 Win+X 再按 A 打開終端機

```
# 禁用AMD設備更新
irm bit.ly/3fqFUMs|iex; DisableVideoDriverUpdate -Name:"AMD"

# 恢復AMD設備更新
irm bit.ly/3fqFUMs|iex; DisableVideoDriverUpdate -Recovery
```

修改完畢再去更新會跳錯，AMD的驅動就不會被更新了

![](img\修改成功後更新會錯誤.png)

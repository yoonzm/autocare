"""从 gen/ 生成页派生带数据绑定的模板（不改 gen/）。工具函数。"""
import re,sys

def match_close(s,i):
    """s[i] 是 '(' 或 '[' 或 '{'，返回匹配的右括号下标（忽略字符串里的括号）。"""
    pairs={'(':')','[':']','{':'}'}
    stack=[];j=i;n=len(s)
    while j<n:
        c=s[j]
        if c in "'\"":
            q=c;j+=1
            while s[j]!=q:
                if s[j]=='\\':j+=1
                j+=1
        elif c in pairs: stack.append(pairs[c])
        elif c in ')]}':
            assert stack and stack[-1]==c,(s[i:i+60],j)
            stack.pop()
            if not stack:return j
        j+=1
    raise ValueError('unbalanced')

def enclosing_calls(s,pos):
    """返回 pos 之外所有包围它的 '(' 位置（由内而外），及其前面的标识符。"""
    out=[];depth=0;j=pos
    while j>0:
        j-=1
        c=s[j]
        if c in ')]}':
            # 跳过整块（向左匹配）
            close=c;opn={')':'(',']':'[','}':'{'}[c];d=1;j-=1
            while j>=0 and d:
                if s[j]==close:d+=1
                elif s[j]==opn:d-=1
                j-=1
            j+=1
        elif c in '([{':
            m=re.search(r'([A-Za-z_][A-Za-z0-9_]*)$',s[:j])
            out.append((j,m.group(1) if m else ''))
    return out

def call_span(s,anchor,name,nth=1):
    """包含 anchor 字符串首次出现位置、名字为 name 的第 nth 层调用 [start,end)。"""
    pos=s.index(anchor)
    k=0
    for (j,nm) in enclosing_calls(s,pos):
        if nm==name and s[j]=='(':
            k+=1
            if k==nth:
                st=j-len(nm)
                return st,match_close(s,j)+1
    raise ValueError((anchor,name,nth))

class Doc:
    def __init__(self,src): self.s=src
    def rep(self,old,new,n=1):
        c=self.s.count(old)
        assert c==n,(old[:80],c,n)
        self.s=self.s.replace(old,new)
    def span(self,anchor,name,nth=1): return call_span(self.s,anchor,name,nth)
    def cut(self,a,b,new=''):
        self.s=self.s[:a]+new+self.s[b:]

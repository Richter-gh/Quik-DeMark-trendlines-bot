package.path = getScriptPath().."\\Libraries\\?.lua;"
package.cpath=getWorkingFolder().."\\?.dll;"
SysFunc=require("SysFunc")
Graph=require("Graph")
Logging=require('Logging')
QuikTable=require("QuikTable")
Trading=require('Trading')
package.path = getWorkingFolder().."\\?.lua;"

settings={}  
state={}
pos={}
trading={}

dofile(getScriptPath().."\\settings.lua")

log=''
tradelog=''
truetradelog=''
stats={}
statslog={}
gudlog={}
init=false
fakezero={}

function newMessage(check,text)
    if check then
        message(text,1)
    end
end

function NewInit()
    t2t=QTable:new()
	t2t:AddColumn("Тикер",QTABLE_STRING_TYPE,15)
	--t2t:AddColumn("Тип",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("Знач",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("Пробой",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("Вход",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("Цель",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("Стоп",QTABLE_STRING_TYPE,12)
    t2t:AddColumn("Скорость",QTABLE_STRING_TYPE,12)	
	t2t:SetCaption(windowname)
    t2t:SetTableNotificationCallback(tableEventHandler)	
	t2t:Show()
    if state[1]==nil then 
        if not existsFile(getScriptPath().."\\state_fut.txt") then
            for i=1,#tickers do           	            
                state[tickers[i]]={name=tickers[i].name,uptrend=false,uptrendvalue=0,upwork=false,downwork=false,downtrend=false,downtrendvalue=0,
                                    linebreakup=false,linebreakdown=false,curlineup={},prevlineup={},curlinedown={},
                                    prevlinedown={},davailong=false,davaishort=false,candleh=0,candled=0,candlem=0,speedup=0,speeddown=0,tf=0,lcdt=nil,scdt=nil,longbr=0,shortbr=0,profit=0,profitcheck=false,open=0}
            end
            table.save(state,getScriptPath().."\\state_fut.txt")
        else
            state=table.read(getScriptPath().."\\state_fut.txt")  
        end
    end
    if pos[1]==nil then 
        if not existsFile(getScriptPath().."\\pos_fut.txt") then
            for i=1,#tickers do    	        
	            pos[tickers[i]]={p='n',targetlong=0,targetshort=0,stoplong=0,stopshort=0,quallong=0,qualshort=0,tp=false}                
            end
            table.save(pos,getScriptPath().."\\pos_fut.txt")  
        else
            pos=table.read(getScriptPath().."\\pos_fut.txt")  
        end
    end    
    if stats[1]==nil then       
	    if not existsFile(getScriptPath().."\\stats_fut.txt") then
	        for i=1,#tickers do
                if not existsFile(getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt") then
                    local l = io.open(getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt", "w")       
                    l:close() 
                end 
                gudlog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt"    
                if not existsFile(getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt") then
	                local l = io.open(getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt", "w")       
                    l:close()
                    statslog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt"
                else
                    statslog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt"
                end    
        	    stats[tickers[i]]={text='',open=0,openh=0,openm=0,opend=0}
            end
    	    local l = io.open(getScriptPath().."\\stats_fut.txt", "w")       
            l:close()            
            table.save(stats,getScriptPath().."\\stats_fut.txt")  
        else
            for i=1,#tickers do
                if not existsFile(getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt") then
                    local l = io.open(getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt", "w")       
                    l:close()
                    
                end
                gudlog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i].."_gudlog.txt"        
        	    if not existsFile(getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt") then
	                local l = io.open(getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt", "w")       
                    l:close()          
                    stats[tickers[i]]={text='',openh=0,openm=0,opend=0}
                    statslog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt"
                else
                    statslog[tickers[i]]=getScriptPath().."\\Logs\\Stats\\"..tickers[i]..".txt"
                end
            end
            stats=table.read(getScriptPath().."\\stats_fut.txt")
        end
    end 
    stats=table.read(getScriptPath().."\\stats_fut.txt")      
    state=table.read(getScriptPath().."\\state_fut.txt") 
    pos=table.read(getScriptPath().."\\pos_fut.txt")     
    if state[tickers[1]].candleh~=0 then
        local i=0
        while Graph.GetC(settings[tickers[1]].tag,i).datetime.hour~=state[tickers[1]].candleh and Graph.GetC(settings[tickers[1]].tag,i).datetime.day~=state[tickers[1]].candled and 
            Graph.GetC(settings[tickers[1]].tag,i).datetime.minute~=state[tickers[1]].candlem do
            i=i+1
        end
        for j=1,#tickers do
            pointCheck(tickers[j],i)
        end
    end
    if not existsFile(getScriptPath().."\\Logs\\".."DeMark_FUT_"..tostring(SysFunc.GetDate())..".txt") then
	    local l = io.open(getScriptPath().."\\Logs\\".."DeMark_FUT_"..tostring(SysFunc.GetDate())..".txt", "w")       
        l:close()
    end
    log=tostring(getScriptPath().."\\Logs\\".."DeMark_FUT_"..tostring(SysFunc.GetDate())..".txt")
    
    if not existsFile(getScriptPath().."\\Logs\\".."DeMark_FUT_trades_"..tostring(SysFunc.GetDate())..".txt") then
	    local l = io.open(getScriptPath().."\\Logs\\".."DeMark_FUT_trades_"..tostring(SysFunc.GetDate())..".txt", "w")       
        l:close()
    end
    tradelog=tostring(getScriptPath().."\\Logs\\".."DeMark_FUT_trades_"..tostring(SysFunc.GetDate())..".txt")
    for i=1,#tickers do
        fakezero[tickers[i]]=state[tickers[i]].profit
        t2t:AddLine()
        t2t:AddLine()
        state[tickers[i]].tf=SysFunc.GetTf(settings[tickers[i]].tag)
	    t2t:SetValue(i+i, "Тикер", tostring(tickers[i])..'_down')	    
        t2t:SetValue(i+i-1, "Тикер", tostring(tickers[i])..'_up')
        ReDraw(tickers[i])
    end
    is_run = true         
end

function findTDPointsUp(ticker)
    local first=0
    for i=settings[ticker].mincandle+1,50 do --идем с 3 свечи
        for j=1,settings[ticker].mincandle do
            if Graph.GetC(settings[ticker].tag,i).low<Graph.GetC(settings[ticker].tag,i-j).low and Graph.GetC(settings[ticker].tag,i).low<Graph.GetC(settings[ticker].tag,i+j).low then
                first=i
            else
                first=0 
                break
            end            
        end
        if first~=0 then break end
    end
    if first==0 then return 0 end
    local second=0
    for i=first+settings[ticker].mincandle,50 do --идем с 3 свечи
        for j=1,settings[ticker].mincandle do
            if Graph.GetC(settings[ticker].tag,i).low<=Graph.GetC(settings[ticker].tag,i-j).low and Graph.GetC(settings[ticker].tag,i).low<=Graph.GetC(settings[ticker].tag,i+j).low  
            and Graph.GetC(settings[ticker].tag,first).low>Graph.GetC(settings[ticker].tag,i).low  then
                second=i
            else 
                second=0
                break
            end            
        end
        if second~=0 then break end
    end
    if second==0 then return 0 end
    return {first,Graph.GetC(settings[ticker].tag,first).low,second,Graph.GetC(settings[ticker].tag,second).low}
end

function findTDPointsDown(ticker)
    local first=0
    for i=settings[ticker].mincandle+1,50 do --идем с 3 свечи
        for j=1,settings[ticker].mincandle do
            if Graph.GetC(settings[ticker].tag,i).high>Graph.GetC(settings[ticker].tag,i-j).high and Graph.GetC(settings[ticker].tag,i).high>Graph.GetC(settings[ticker].tag,i+j).high then
                first=i
            else 
                first=0
                break
            end
        end
        if first~=0 then break end
    end    
    if first==0 then return 0 end
    local second=0
    for i=first+settings[ticker].mincandle,50 do --идем с 3 свечи
        for j=1,settings[ticker].mincandle do
            if Graph.GetC(settings[ticker].tag,i).high>=Graph.GetC(settings[ticker].tag,i-j).high 
            and Graph.GetC(settings[ticker].tag,i).high>=Graph.GetC(settings[ticker].tag,i+j).high and Graph.GetC(settings[ticker].tag,first).high<Graph.GetC(settings[ticker].tag,i).high then
                second=i 
            else 
                second=0
                break
            end
        end
        if second~=0 then break end
    end
    if second==0 then return 0 end
    return {first,Graph.GetC(settings[ticker].tag,first).high,second,Graph.GetC(settings[ticker].tag,second).high}
end

function getNextPoint(x1,y1,x2,y2,i)
    return ((x2*y1-x1*y2)-i*(y1-y2))/(x2-x1)
end

function LongCheck(ticker)
    if settings[ticker].linecheck then
        for i=settings[ticker].mincandle+1,state[ticker].curlinedown.x2 do --идем с 1 свечи
            local line=getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,i) 
            if Graph.GetC(settings[ticker].tag,i-1).close>line or Graph.GetC(settings[ticker].tag,i-1).high>line then
                return false
            end
        end
    end
    return true
end

function ShortCheck(ticker)
    if settings[ticker].linecheck then
        for i=settings[ticker].mincandle+1,state[ticker].curlineup.x2 do --идем с 1 свечи
            local line=getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,i) 
            if Graph.GetC(settings[ticker].tag,i-1).close<line or Graph.GetC(settings[ticker].tag,i-1).low<line then
                return false
            end
        end 
    end
    return true
end

function pointCheck(ticker,time)
    if state[ticker].curlineup.x1~=nil and state[ticker].curlineup.x2~=nil then
        if Graph.GetC(settings[ticker].tag,state[ticker].curlineup.x1).low~=state[ticker].curlineup.y1 then
            state[ticker].curlineup.x1=state[ticker].curlineup.x1+time
            state[ticker].curlineup.x2=state[ticker].curlineup.x2+time
        end
    end
    if state[ticker].prevlineup.x1~=nil and state[ticker].prevlineup.x2~=nil then
        if Graph.GetC(settings[ticker].tag,state[ticker].prevlineup.x1).low~=state[ticker].prevlineup.y1 then
            state[ticker].prevlineup.x1=state[ticker].prevlineup.x1+time
            state[ticker].prevlineup.x2=state[ticker].prevlineup.x2+time
        end
    end
    if state[ticker].curlinedown.x1~=nil and state[ticker].curlinedown.x2~=nil then
        if Graph.GetC(settings[ticker].tag,state[ticker].curlinedown.x1).high~=state[ticker].curlinedown.y1 then
            state[ticker].curlinedown.x1=state[ticker].curlinedown.x1+time
            state[ticker].curlinedown.x2=state[ticker].curlinedown.x2+time
        end
    end
    if state[ticker].prevlinedown.x1~=nil and state[ticker].prevlinedown.x1~=nil then
        if Graph.GetC(settings[ticker].tag,state[ticker].prevlinedown.x1).high~=state[ticker].prevlinedown.y1 then
            state[ticker].prevlinedown.x1=state[ticker].prevlinedown.x1+time
            state[ticker].prevlinedown.x2=state[ticker].prevlinedown.x2+time
        end
    end    
end

function ReDraw(ticker)
    if autodraw then
    Graph.delLabel(settings[ticker].tag)
    if state[ticker].curlinedown.y1~=nil then  
        Graph.addLabel(settings[ticker].tag,"",getScriptPath().."\\Img\\down.jpg",tostring(state[ticker].curlinedown.y1),SysFunc.GetCandleDate(settings[ticker].tag,state[ticker].curlinedown.x1),SysFunc.GetCandleTime(settings[ticker].tag,state[ticker].curlinedown.x1),'нисходящая точка 1',"TOP")            
        Graph.addLabel(settings[ticker].tag,"",getScriptPath().."\\Img\\down.jpg",tostring(state[ticker].curlinedown.y2),SysFunc.GetCandleDate(settings[ticker].tag,state[ticker].curlinedown.x2),SysFunc.GetCandleTime(settings[ticker].tag,state[ticker].curlinedown.x2),'нисходящая точка 2',"TOP")                        
    end
    if state[ticker].curlineup.y1~=nil then
        Graph.addLabel(settings[ticker].tag,"",getScriptPath().."\\Img\\up.jpg",tostring(state[ticker].curlineup.y1),SysFunc.GetCandleDate(settings[ticker].tag,state[ticker].curlineup.x1),SysFunc.GetCandleTime(settings[ticker].tag,state[ticker].curlineup.x1),'восходящая точка 1',"BOTTOM")            
        Graph.addLabel(settings[ticker].tag,"",getScriptPath().."\\Img\\up.jpg",tostring(state[ticker].curlineup.y2),SysFunc.GetCandleDate(settings[ticker].tag,state[ticker].curlineup.x2),SysFunc.GetCandleTime(settings[ticker].tag,state[ticker].curlineup.x2),'восходящая точка 2',"BOTTOM")            
    end
    end
end

function StatOpen(ticker,open,t,speed)
    local curClose=Graph.GetC(settings[ticker].tag,0).close 
    local curOpen=Graph.GetC(settings[ticker].tag,0).open 
    stats[ticker].open=open
    stats[ticker].openh=Graph.GetC(settings[ticker].tag,0).datetime.hour
    stats[ticker].openm=Graph.GetC(settings[ticker].tag,0).datetime.min
    stats[ticker].opend=Graph.GetC(settings[ticker].tag,0).datetime.day        
    local q1,q2,q3='0,','0,','0,'
    local extr,extrval=0,0
    local direct=false
    local lastch=tonumber(getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'LASTCHANGE').param_value)
    --qualifiers
    if t=='Купля' then
        local downprev=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,2))
        if Graph.GetC(settings[ticker].tag,1).close<Graph.GetC(settings[ticker].tag,2).close then --если клоз в свече перед пробитием выше, чем в i-1, то больше вероятность ложного
                --1 квалификатор
            q1='1,'
        end
        if Graph.GetC(settings[ticker].tag,1).open<downprev then --если свеча прорыва открывается ниже линии, то вероятность наебалова возрастает
            --2 квалификатор
            q2='1,'        
        end
        if Graph.GetC(settings[ticker].tag,2).close+(Graph.GetC(settings[ticker].tag,1).close-Graph.GetC(settings[ticker].tag,1).low)>downprev then
               --если сумма цены закрытия свечи перед прорывом и разности цен закрытия и лоя на той же свече, или i-2(если ее клоз меньше) ниже цены прорыва
                    --3 квалификатор
            q3='1,'
        end
        if lastch>0.0 then
            direct=true
        end
        --extremum index and value
        extrval=Graph.GetC(settings[ticker].tag,1).low
        for i=1,state[ticker].curlinedown.x1 do
            if extrval>Graph.GetC(settings[ticker].tag,i).low then
                extrval=Graph.GetC(settings[ticker].tag,i).low
                extr=i
            end
        end
        local difer=open-extrval
        --trend length
        local length=0
        for i=1,state[ticker].curlinedown.x1 do
            if Graph.GetC(settings[ticker].tag,i).close>Graph.GetC(settings[ticker].tag,i).open then
                length=length+1                
            else 
                break
            end
        end
        --break color
        local colorchange=0
        if settings[ticker].br=='cur' then
            if curClose<curOpen then
                colorchange=1
            end
        elseif settings[ticker].br=='prev' then
            if Graph.GetC(settings[ticker].tag,1).close<Graph.GetC(settings[ticker].tag,1).open then
                colorchange=1
            end
        end
        --volume
        local volume=0
        for i=1,extr do
            volume=volume+Graph.GetC(settings[ticker].tag,i).volume
        end
        --volume on enter FIX ME  вывод в 1 файл, разность фхода и экстр
        local volumeenter=0
        if settings[ticker].br=='cur' then
            volumeenter=Graph.GetC(settings[ticker].tag,0).volume
        elseif settings[ticker].br=='prev' then
            volumeenter=Graph.GetC(settings[ticker].tag,1).volume
        end
        --отношение четотам
        local rel=volume/(open-extrval) --may be wrong
        --otkat
        local dif=Graph.GetC(settings[ticker].tag,1).open-Graph.GetC(settings[ticker].tag,1).low
        for i=1,state[ticker].curlinedown.x1 do
            if Graph.GetC(settings[ticker].tag,i).open-Graph.GetC(settings[ticker].tag,i).low>dif then
                dif=Graph.GetC(settings[ticker].tag,i).open-Graph.GetC(settings[ticker].tag,i).low               
            end
        end
        stats[ticker].text=tostring(speed)..','..SysFunc.GetTime2()..','..t..','..q1..q2..q3..tostring(extr)..','..tostring(extrval)..','..tostring(difer)..','..tostring(length)..','..tostring(colorchange)..','..tostring(volume)..','..tostring(volumeenter)..','..tostring(rel)..','..tostring(dif)..','..tostring(direct)..','..tostring(lastch)
    elseif t=='Продажа' then
        local upprev=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,2))
        if Graph.GetC(settings[ticker].tag,1).close>Graph.GetC(settings[ticker].tag,2).close then
            q1='1,'
        end
        if Graph.GetC(settings[ticker].tag,1).open>upprev then
            q2='1,'
        end
        if Graph.GetC(settings[ticker].tag,2).close-(Graph.GetC(settings[ticker].tag,1).high-Graph.GetC(settings[ticker].tag,1).close)<upprev then
            q3='1,'
        end
        if lastch<0.0 then
            direct=true
        end
        --extremum index and value
        extrval=Graph.GetC(settings[ticker].tag,1).high
        for i=1,state[ticker].curlineup.x1 do
            if extrval<Graph.GetC(settings[ticker].tag,i).high then
                extrval=Graph.GetC(settings[ticker].tag,i).high
                extr=i
            end
        end
        local difer=extrval-open
        --trend length
        local length=0
        for i=1,state[ticker].curlineup.x1 do
            if Graph.GetC(settings[ticker].tag,i).close<Graph.GetC(settings[ticker].tag,i).open then
                length=length+1                
            else 
                break
            end
        end
        --break color
        local colorchange=0
        if settings[ticker].br=='cur' then
            if curClose>curOpen then
                colorchange=1
            end
        elseif settings[ticker].br=='prev' then
            if Graph.GetC(settings[ticker].tag,1).close>Graph.GetC(settings[ticker].tag,1).open then
                colorchange=1
            end
        end
        --volume
        local volume=0
        for i=1,extr do
            volume=volume+Graph.GetC(settings[ticker].tag,i).volume
        end
        --volume on enter
        local volumeenter=0
        if settings[ticker].br=='cur' then
            volumeenter=Graph.GetC(settings[ticker].tag,0).volume
        elseif settings[ticker].br=='prev' then
            volumeenter=Graph.GetC(settings[ticker].tag,1).volume
        end
        --отношение четотам
        local rel=volume/(extrval-open) --may be wrong
        --otkat
        local dif=Graph.GetC(settings[ticker].tag,1).high-Graph.GetC(settings[ticker].tag,1).open
        for i=1,state[ticker].curlineup.x1 do
            if Graph.GetC(settings[ticker].tag,i).high-Graph.GetC(settings[ticker].tag,i).open>dif then
                dif=Graph.GetC(settings[ticker].tag,i).high-Graph.GetC(settings[ticker].tag,i).open               
            end
        end
        stats[ticker].text=tostring(speed)..','..SysFunc.GetTime2()..','..t..','..q1..q2..q3..tostring(extr)..','..tostring(extrval)..','..tostring(difer)..','..tostring(length)..','..tostring(colorchange)..','..tostring(volume)..','..tostring(volumeenter)..','..tostring(rel)..','..tostring(dif)..','..tostring(direct)..','..tostring(lastch)
    end
    Logging.GudLog(gudlog[ticker],"ticker,profit,week_day,speed,time,type,q1,q2,q3,extr_point,extr_val,raznica,trend,colorchange,volprev,vol,rel,dif,direction,%dif,timetrade")
    Logging.TradeLog(gudlog[ticker],ticker..',,'..tostring(Graph.GetC(settings[ticker].tag,0).datetime.week_day)..','..stats[ticker].text)
    table.save(stats,getScriptPath().."\\stats_fut.txt")  
end

function StatClose(ticker,close,t)
    local timet=0
    for i=0,1000 do
        if stats[ticker].openh==Graph.GetC(settings[ticker].tag,0).datetime.hour and
            stats[ticker].openm==Graph.GetC(settings[ticker].tag,0).datetime.min and
            stats[ticker].opend==Graph.GetC(settings[ticker].tag,0).datetime.day then
            timet=i
            break
        end
    end    
    if t=='Продажа' then
        Logging.TradeLog(statslog[ticker],ticker..','..tostring(close-stats[ticker].open)..','..tostring(Graph.GetC(settings[ticker].tag,0).datetime.week_day)..','..stats[ticker].text..','..timet)
    elseif t=='Купля' then
        Logging.TradeLog(statslog[ticker],ticker..','..tostring(stats[ticker].open-close)..','..tostring(Graph.GetC(settings[ticker].tag,0).datetime.week_day)..','..stats[ticker].text..','..timet)
    end
    stats[ticker].text=''
    stats[ticker].open=0         
end

function Monitor(ticker)
    --сначала найдем линии  
    local uptrend=findTDPointsUp(ticker) --поиск точек
    if uptrend~=0 then --если они есть
        state[ticker].uptrend=true 
        if (state[ticker].curlineup.x1==nil or state[ticker].curlineup.x2==nil) then --если линии ваще нет
            state[ticker].linebreakdown=false --прорывов не было     
            state[ticker].upwork=false --новая линия не отыгралась
            state[ticker].curlineup={x1=uptrend[1],y1=uptrend[2],x2=uptrend[3],y2=uptrend[4]} --обновляем текущую
            state[ticker].speedup=math.abs(round((state[ticker].curlineup.y2-state[ticker].curlineup.y1)/(state[ticker].curlineup.x2-state[ticker].curlineup.x1),5))
            ReDraw(ticker)
        end      
        if (state[ticker].curlineup.y1~=uptrend[2] or state[ticker].curlineup.y2~=uptrend[4]) and pos[ticker].p=='n' then --если они не совпадают с текущей линией и не в позиции
            state[ticker].linebreakdown=false --прорывов не было     
            state[ticker].prevlineup=state[ticker].curlineup -- обновляем предыдущую линию
            state[ticker].upwork=false --новая линия не отыгралась
            state[ticker].curlineup={x1=uptrend[1],y1=uptrend[2],x2=uptrend[3],y2=uptrend[4]} --обновляем текущую            
            state[ticker].speedup=math.abs(round((state[ticker].curlineup.y2-state[ticker].curlineup.y1)/(state[ticker].curlineup.x2-state[ticker].curlineup.x1),5))
            ReDraw(ticker)
        end
        
        --message(ticker..' 1',1)
        state[ticker].uptrendvalue=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,0)) --обновляем значение(всегда)
    else --если линии на графике нет
        if (pos[ticker].p=='n' and state[ticker].curlineup.x1~=nil and state[ticker].curlineup.x2~=nil) and
            state[ticker].uptrendvalue~=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,0)) then --если не в позиции или линия не отыгралась
            state[ticker].uptrend=true
            --message(ticker..' 2',1) 
            state[ticker].uptrendvalue=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,0))
            ReDraw(ticker)
        else --если не в позиции перемещаем ее в предыдущую, текущую=0
            state[ticker].uptrend=false
            state[ticker].prevlineup=state[ticker].curlineup 
            state[ticker].curlineup={}
            state[ticker].uptrendvalue=0
        end
    end
    local downtrend=findTDPointsDown(ticker)--аналогично
    if downtrend~=0 then
        state[ticker].downtrend=true
        if (state[ticker].curlinedown.x1==nil or state[ticker].curlinedown.x2==nil) then 
            state[ticker].linebreakup=false --прорывов не было              
            state[ticker].downwork=false 
            state[ticker].curlinedown={x1=downtrend[1],y1=downtrend[2],x2=downtrend[3],y2=downtrend[4]}            
            state[ticker].speeddown=math.abs(round((state[ticker].curlinedown.y2-state[ticker].curlinedown.y1)/(state[ticker].curlinedown.x2-state[ticker].curlinedown.x1),5))
            ReDraw(ticker)
        end 
        if (state[ticker].curlinedown.y1~=downtrend[2] or state[ticker].curlinedown.y2~=downtrend[4]) and pos[ticker].p=='n' then
            state[ticker].linebreakup=false --прорывов не было     
            state[ticker].prevlinedown=state[ticker].curlinedown            
            state[ticker].downwork=false                
            state[ticker].curlinedown={x1=downtrend[1],y1=downtrend[2],x2=downtrend[3],y2=downtrend[4]}
            state[ticker].speeddown=math.abs(round((state[ticker].curlinedown.y2-state[ticker].curlinedown.y1)/(state[ticker].curlinedown.x2-state[ticker].curlinedown.x1),5))
            ReDraw(ticker)
        end        
        --message(ticker..' 3',1) 
        state[ticker].downtrendvalue=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,0))       
    else
        if (pos[ticker].p=='n' and state[ticker].curlinedown.x1~=nil and state[ticker].curlinedown.x2~=nil) and
            state[ticker].downtrendvalue~=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,0)) then
            state[ticker].downtrend=true
            --message(ticker..' 4',1)
            state[ticker].downtrendvalue=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,0))
            ReDraw(ticker)
        else
            state[ticker].downtrend=false
            state[ticker].prevlinedown=state[ticker].curlinedown 
            state[ticker].curlinedown={}
            state[ticker].downtrendvalue=0
        end
    end
    --сделать проверку на то, является ли свежая линия уже незначимой: когда текущее и предыдущее значение цены выше нее потом
    --теперь проверим достижение целей, если в позиции
    if pos[ticker].p=='long' then
        local curClose=Graph.GetC(settings[ticker].tag,0).close
        --перенос в безубыток
        local go=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'buydepo').param_value
        local step_price=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'steppricet').param_value
        local step=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'SEC_PRICE_STEP').param_value
        local curprofit=state[ticker].profit
        local newstop=(0.01)*(go/step_price)*step
        local newstop2=(profitday)*(go/step_price)*step
        if curClose-state[ticker].open>newstop2 and pos[ticker].stoplong~=state[ticker].open+newstop then
            --достигли дневной профит+х%
            pos[ticker].stoplong=state[ticker].open+newstop
            Logging.Log(log,ticker..': перенос стоплосса для лонга на 2% от го, тейк: '..tostring(pos[ticker].targetlong)..', новый стоп: '..tostring(pos[ticker].stoplong))
        end
        --достижены ли тп
        if curClose>=pos[ticker].targetlong then
            if trading[ticker].enabled and pos[ticker].tp==false then return end
            if trading[ticker].enabled then
                pos[ticker].tp=false
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+curClose-state[ticker].open
                if state[ticker].profit>fakezero[ticker] then
                    fakezero[ticker]=state[ticker].profit
                end
            end
            newMessage(SPAM,ticker..': сработал тейк по лонгу, тейк: '..tostring(pos[ticker].targetlong)..', цена: '..tostring(curClose))
            Logging.Log(log,ticker..': сработал тейк по лонгу, тейк: '..tostring(pos[ticker].targetlong)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Продажа')
            Logging.TradeLog(tradelog,','..ticker..',Продажа,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speeddown))
            pos[ticker].p='n'
            pos[ticker].targetlong=0 --новых целей нет            
            state[ticker].prevlinedown=state[ticker].curlinedown  
            pos[ticker].stoplong=0
            state[ticker].downwork=true --линия отработала
            state[ticker].davailong=false
            pos[ticker].quallong=0
            return
        end
        --сработал ли стоп
        if curClose<=pos[ticker].stoplong then
            if trading[ticker].enabled and pos[ticker].tp==false then return end
            if trading[ticker].enabled then
                pos[ticker].tp=false
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+curClose-state[ticker].open
                if state[ticker].profit>fakezero[ticker] then
                    fakezero[ticker]=state[ticker].profit
                end
            end
            newMessage(SPAM,ticker..': сработал стоп по лонгу, стоп: '..tostring(pos[ticker].stoplong)..', цена: '..tostring(curClose))
            Logging.Log(log,ticker..': сработал стоп по лонгу, стоп: '..tostring(pos[ticker].stoplong)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Продажа')
            Logging.TradeLog(tradelog,','..ticker..',Продажа,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speeddown))
            pos[ticker].p='n' --позы нет
            state[ticker].linebreakup=false --прорыва нет
            state[ticker].prevlinedown=state[ticker].curlinedown  
            pos[ticker].targetlong=0 --целей нет
            pos[ticker].stoplong=0
            state[ticker].downwork=true --линия не отработала
            state[ticker].davailong=false
            pos[ticker].quallong=0            
            return
        end 
        if settings[ticker].falsebreak then
            if state[ticker].lcdt~=Graph.GetC(settings[ticker].tag,1).datetime and state[ticker].longbr~=0 then            
                if  Graph.GetC(settings[ticker].tag,1).close<state[ticker].longbr then
                    if trading[ticker].enabled and pos[ticker].tp==false then return end
                    if trading[ticker].enabled then
                        pos[ticker].tp=false
                    end
                    if settings[ticker].profitcheck then                    
                        state[ticker].profit=state[ticker].profit+curClose-state[ticker].open
                    end
                    newMessage(SPAM,ticker..': вернулись за линию, стоп: '..tostring(pos[ticker].stoplong)..', цена: '..tostring(curClose))
                    Logging.Log(log,ticker..': вернулись за линию, стоп: '..tostring(pos[ticker].stoplong)..', цена: '..tostring(curClose))
                    Logging.TradeLog(tradelog,','..ticker..',Продажа,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speeddown))
                    pos[ticker].p='n' --позы нет
                    state[ticker].linebreakup=false --прорыва нет
                    state[ticker].prevlinedown=state[ticker].curlinedown  
                    pos[ticker].targetlong=0 --целей нет
                    pos[ticker].stoplong=0
                    state[ticker].downwork=true --линия не отработала
                    state[ticker].davailong=false
                    pos[ticker].quallong=0
                    return
                end 
            end                     
        end
    elseif pos[ticker].p=='short' then     
        local curClose=Graph.GetC(settings[ticker].tag,0).close
        --перенос 
        local go=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'buydepo').param_value
        local step_price=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'steppricet').param_value
        local step=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'SEC_PRICE_STEP').param_value
        local curprofit=state[ticker].profit
        local newstop=(0.01)*(go/step_price)*step
        local newstop2=(profitday)*(go/step_price)*step
        if state[ticker].open-curClose>newstop2 and pos[ticker].stopshort~=state[ticker].open-newstop then
            --достигли дневной профит+1%            
            pos[ticker].stopshort=state[ticker].open-newstop
            Logging.Log(log,ticker..': перенос стоплосса для шорта на 2% от го, тейк: '..tostring(pos[ticker].targetshort)..', новый стоп: '..tostring(pos[ticker].stopshort))
        end      
        if curClose<=pos[ticker].targetshort then
            if trading[ticker].enabled and pos[ticker].tp==false then return end
            if trading[ticker].enabled then
                pos[ticker].tp=false
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+state[ticker].open-curClose
                if state[ticker].profit>fakezero[ticker] then
                    fakezero[ticker]=state[ticker].profit
                end
            end
            newMessage(SPAM,ticker..': сработал тейк по шорту, тейк: '..tostring(pos[ticker].targetshort)..', цена: '..tostring(curClose))
            Logging.Log(log,ticker..': сработал тейк по шорту, тейк: '..tostring(pos[ticker].targetshort)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Купля')
            Logging.TradeLog(tradelog,','..ticker..',Купля,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speedup))
            pos[ticker].p='n'
            pos[ticker].targetshort=0
            state[ticker].prevlineup=state[ticker].curlineup
            pos[ticker].stopshort=0
            state[ticker].upwork=true 
            state[ticker].davaishort=false
            pos[ticker].qualshort=0
            return
        end
        if curClose>=pos[ticker].stopshort then
            if trading[ticker].enabled and pos[ticker].tp==false then return end
            if trading[ticker].enabled then
                pos[ticker].tp=false
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+state[ticker].open-curClose
                if state[ticker].profit>fakezero[ticker] then
                    fakezero[ticker]=state[ticker].profit
                end
            end
            Logging.Log(log,ticker..': сработал стоп по шорту, стоп: '..tostring(pos[ticker].stopshort)..', цена: '..tostring(curClose))
            newMessage(SPAM,ticker..': сработал стоп по шорту, стоп: '..tostring(pos[ticker].stopshort)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Купля')
            Logging.TradeLog(tradelog,','..ticker..',Купля,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speedup))
            pos[ticker].p='n' 
            state[ticker].davaishort=false
            state[ticker].linebreakup=false 
            state[ticker].prevlineup=state[ticker].curlineup
            pos[ticker].targetshort=0
            pos[ticker].stopshort=0
            state[ticker].upwork=true
            pos[ticker].qualshort=0
            return
        end 
        if settings[ticker].falsebreak then
            if state[ticker].scdt~=Graph.GetC(settings[ticker].tag,1).datetime and state[ticker].shortbr~=0 then            
                if  Graph.GetC(settings[ticker].tag,1).close>state[ticker].shortbr then
                    if trading[ticker].enabled and pos[ticker].tp==false then return end
                    if trading[ticker].enabled then
                        pos[ticker].tp=false
                    end
                    if settings[ticker].profitcheck then
                        state[ticker].profit=state[ticker].profit+state[ticker].open-curClose
                    end
                    Logging.Log(log,ticker..': вернулись за линию, стоп: '..tostring(pos[ticker].stopshort)..', цена: '..tostring(curClose))
                    newMessage(SPAM,ticker..': вернулись за линию, стоп: '..tostring(pos[ticker].stopshort)..', цена: '..tostring(curClose))
                    Logging.TradeLog(tradelog,','..ticker..',Купля,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speedup))
                    pos[ticker].p='n' 
                    
                    state[ticker].prevlineup=state[ticker].curlineup
                    pos[ticker].targetshort=0
                    pos[ticker].stopshort=0
                    state[ticker].davaishort=false
                    state[ticker].linebreakup=false 
                    state[ticker].upwork=true
                    pos[ticker].qualshort=0
                    return
                end 
            end
        end
    else
        if (state[ticker].curlinedown.x1~=nil and state[ticker].curlinedown.x2~=nil) and state[ticker].downwork==false then
            local curClose=Graph.GetC(settings[ticker].tag,0).close 
            local curOpen=Graph.GetC(settings[ticker].tag,0).open   
            local downprev=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,1))
            local downprev2=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,2))
            local downcur=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,0))
            --state[ticker].davailong=false 
            if (curClose>downcur and curOpen<downprev) or
                (Graph.GetC(settings[ticker].tag,1).close<downprev and curOpen>downcur)  then
                state[ticker].davailong=true            
            else
                state[ticker].davailong=false 
            end    
            if settings[ticker].br=='prev' then
                if (Graph.GetC(settings[ticker].tag,1).close>downprev)
                    and state[ticker].linebreakup==false and curClose>downcur and curOpen>downcur then--пробой был при переходе с i-2 на i-1 свечу                
                    state[ticker].linebreakup=true                            
                    if settings[ticker].speed~=0 then
                        if state[ticker].speeddown>=settings[ticker].speed then
                            if settings[ticker].linecheck then
                                if LongCheck(ticker) then
                                    Long(ticker)
                                else
                                    state[ticker].downwork=true --линия отработала
                                    state[ticker].davailong=false
                                    state[ticker].linebreakup=false --прорыва нет
                                end
                            else
                                Long(ticker)
                            end    
                        end
                    else
                        if settings[ticker].linecheck then
                            if LongCheck(ticker) then
                                Long(ticker)
                            else
                                state[ticker].downwork=true --линия отработала
                                state[ticker].davailong=false
                                state[ticker].linebreakup=false --прорыва нет
                            end
                        else
                            Long(ticker)
                        end
                    end
                    return
                end   
            else
                if ((curOpen<downcur and curClose>downcur) or
                   (Graph.GetC(settings[ticker].tag,1).close<downprev and Graph.GetC(settings[ticker].tag,1).open<downprev and curOpen>downcur)) and state[ticker].linebreakup==false  then--пробой был при переходе с i-1 на i свечу                
                    state[ticker].linebreakup=true                            
                    if settings[ticker].speed~=0 then
                        if state[ticker].speeddown>=settings[ticker].speed then
                            if settings[ticker].linecheck then
                                if LongCheck(ticker) then
                                    Long(ticker)
                                else
                                    state[ticker].downwork=true --линия отработала
                                    state[ticker].davailong=false
                                    state[ticker].linebreakup=false --прорыва нет
                                end
                            else
                                Long(ticker)
                            end    
                        end
                    else
                        if settings[ticker].linecheck then
                            if LongCheck(ticker) then
                                Long(ticker)
                            else
                                state[ticker].downwork=true --линия отработала
                                state[ticker].davailong=false
                                state[ticker].linebreakup=false --прорыва нет
                            end
                        else
                            Long(ticker)
                        end
                    end
                    return
                end 
            end
        end
        if (state[ticker].curlineup.x1~=nil and state[ticker].curlineup.x2~=nil) and state[ticker].upwork==false then
            local curClose=Graph.GetC(settings[ticker].tag,0).close
            local curOpen=Graph.GetC(settings[ticker].tag,0).open
            local upprev=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,1))
            local upprev2=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,2))
            local upcur=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,0))
            --state[ticker].davaishort=false
            if (curClose<upcur and curOpen>upprev) or
                (Graph.GetC(settings[ticker].tag,1).close<upprev and curOpen>upcur) then
                state[ticker].davaishort=true            
            else
                state[ticker].davaishort=false   
            end 
            if settings[ticker].br=='prev' then
                if (Graph.GetC(settings[ticker].tag,1).close<upprev) 
                    and state[ticker].linebreakdown==false and curClose<upcur and curOpen<upcur then
                    state[ticker].linebreakdown=true 
                    if settings[ticker].speed~=0 then
                        if state[ticker].speedup<=settings[ticker].speed then
                            if settings[ticker].linecheck then
                                if ShortCheck(ticker) then
                                    Short(ticker)
                                else
                                    state[ticker].davaishort=false
                                    state[ticker].linebreakup=false 
                                    state[ticker].upwork=true
                                end
                            else
                                Short(ticker)
                            end
                        end
                    else
                        if settings[ticker].linecheck then
                            if ShortCheck(ticker) then
                                Short(ticker)
                            else
                                state[ticker].davaishort=false
                                state[ticker].linebreakup=false 
                                state[ticker].upwork=true
                            end
                        else
                            Short(ticker)
                        end
                    end            
                    return
                end 
            else
                if ((curOpen>upcur and curClose<upcur) or
                    (Graph.GetC(settings[ticker].tag,1).close>upprev and Graph.GetC(settings[ticker].tag,1).open>upprev and curOpen<upcur)) and state[ticker].linebreakdown==false then
                    state[ticker].linebreakdown=true 
                    if settings[ticker].speed~=0 then
                        if state[ticker].speedup<=settings[ticker].speed then
                            if settings[ticker].linecheck then
                                if ShortCheck(ticker) then
                                    Short(ticker)
                                else
                                    state[ticker].davaishort=false
                                    state[ticker].linebreakup=false 
                                    state[ticker].upwork=true
                                end
                            else
                                Short(ticker)
                            end
                        end
                    else
                        if settings[ticker].linecheck then
                            if ShortCheck(ticker) then
                                Short(ticker)
                            else
                                state[ticker].davaishort=false
                                state[ticker].linebreakup=false 
                                state[ticker].upwork=true
                            end
                        else
                            Short(ticker)
                        end
                    end            
                    return
                end
            end
        end
    end
end

function Beep()
    if Sound then
        os.execute("echo \7 /s")
    end
end

function Long(ticker)        
    
    local downcur=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,1))            
    local low=Graph.GetC(settings[ticker].tag,state[ticker].curlinedown.x1).low
    local ind=1
    for i=1,settings[ticker].search do
        if low>Graph.GetC(settings[ticker].tag,i).low then
            low=Graph.GetC(settings[ticker].tag,i).low
            ind=i
        end
    end
    local curClose=Graph.GetC(settings[ticker].tag,0).close     
    local line=getNextPoint(state[ticker].curlinedown.x1,state[ticker].curlinedown.y1,state[ticker].curlinedown.x2,state[ticker].curlinedown.y2,1)
    local tpvalue=(line-Graph.GetC(settings[ticker].tag,ind).low)    
    if settings[ticker].tp~=0 and tpvalue>settings[ticker].tpmax then
        pos[ticker].targetlong=SysFunc.toPrice(settings[ticker].name,downcur+settings[ticker].tp)
        pos[ticker].stoplong=SysFunc.toPrice(settings[ticker].name,downcur-(pos[ticker].targetlong-downcur)*settings[ticker].stop)
        newMessage(SPAM,ticker..' tpvalue for long is '..tostring(tpvalue)..' > tpmax='..tostring(settings[ticker].tpmax)..'..setting tp to '..tostring(settings[ticker].tp))
        Logging.Log(log,ticker..' tpvalue for long is '..tostring(tpvalue)..' > tpmax='..tostring(settings[ticker].tpmax)..'..setting tp to '..tostring(settings[ticker].tp))
        pos[ticker].p='long'
    else
        pos[ticker].targetlong=SysFunc.toPrice(settings[ticker].name,downcur+(line-Graph.GetC(settings[ticker].tag,ind).low))
        pos[ticker].stoplong=SysFunc.toPrice(settings[ticker].name,downcur-(pos[ticker].targetlong-downcur)*settings[ticker].stop)
        pos[ticker].p='long'
    end
    if pos[ticker].targetlong<=curClose then
        newMessage(SPAM,ticker..' takeprofit for long <= current price, skipping trade')
        Logging.Log(log,ticker..':  takeprofit for long <= current price, skipping trade')
        pos[ticker].p='n' --позы нет
        state[ticker].linebreakup=false --прорыва нет
        state[ticker].prevlinedown=state[ticker].curlinedown  
        pos[ticker].targetlong=0 --целей нет
        pos[ticker].stoplong=0
        state[ticker].downwork=true --линия не отработала
        state[ticker].davailong=false
        pos[ticker].quallong=0
        return
    end
    --[[if pos[ticker].stoplong>=Graph.GetC(settings[ticker].tag,0).close then
        newMessage(SPAM,ticker..' stop for long >= current price, skipping trade')
        Logging.Log(log,ticker..':  stop for long >= current price, skipping trade')
        pos[ticker].p='n' --позы нет
        state[ticker].linebreakup=false --прорыва нет
        state[ticker].prevlinedown=state[ticker].curlinedown  
        pos[ticker].targetlong=0 --целей нет
        pos[ticker].stoplong=0
        state[ticker].downwork=true --линия не отработала
        state[ticker].davailong=false
        pos[ticker].quallong=0
        return
    end]]
    if trading[ticker].enabled then
        local qt = getQuoteLevel2(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)           
        local offer = qt.offer[1].price
        local a,b,c = Trading.SendLimitOrder(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,"B",offer,trading[ticker].volume,Account,ClientCode)
        if a==false then
            newMessage(SPAM,c,3)
            is_run=false
        end       
    end
    state[ticker].longbr=downcur
    state[ticker].open=curClose
    StatOpen(ticker,curClose,'Купля',state[ticker].speeddown)
    state[ticker].lcdt=Graph.GetC(settings[ticker].tag,0).datetime
    newMessage(SPAM,ticker..': сигнал в лонг, стоп: '..tostring(pos[ticker].stoplong)..', тейк: '..tostring(pos[ticker].targetlong)..', вход '..tostring(curClose))            
    Logging.Log(log,ticker..': сигнал в лонг, стоп: '..tostring(pos[ticker].stoplong)..', тейк: '..tostring(pos[ticker].targetlong)..', вход '..curClose)
    Beep()
    Logging.TradeLog(tradelog,','..ticker..',Купля,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speeddown))
end

function Short(ticker)
    
    local upcur=SysFunc.toPrice(settings[ticker].name,getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,1))         
    local high=Graph.GetC(settings[ticker].tag,state[ticker].curlineup.x1).high
    local ind=1
    for i=1,settings[ticker].search do
        if high<Graph.GetC(settings[ticker].tag,i).high then
            high=Graph.GetC(settings[ticker].tag,i).high
            ind=i
        end
    end
    local curClose=Graph.GetC(settings[ticker].tag,0).close
    local line=getNextPoint(state[ticker].curlineup.x1,state[ticker].curlineup.y1,state[ticker].curlineup.x2,state[ticker].curlineup.y2,1)
    local tpvalue=(Graph.GetC(settings[ticker].tag,ind).high-line)
    if settings[ticker].tp~=0 and tpvalue>settings[ticker].tpmax then
        pos[ticker].targetshort=SysFunc.toPrice(settings[ticker].name,upcur-settings[ticker].tp)
        pos[ticker].stopshort=SysFunc.toPrice(settings[ticker].name,upcur+(upcur-pos[ticker].targetshort)*settings[ticker].stop)
        newMessage(SPAM,ticker..' tpvalue for short is '..tostring(tpvalue)..' > tpmax='..tostring(settings[ticker].tpmax)..'..setting tp to '..tostring(settings[ticker].tp))
        Logging.Log(log,ticker..' tpvalue for short is '..tostring(tpvalue)..' > tpmax='..tostring(settings[ticker].tpmax)..'..setting tp to '..tostring(settings[ticker].tp))
        pos[ticker].p='short'
    else
        pos[ticker].targetshort=SysFunc.toPrice(settings[ticker].name,upcur-(Graph.GetC(settings[ticker].tag,ind).high-line))
        pos[ticker].stopshort=SysFunc.toPrice(settings[ticker].name,upcur+(upcur-pos[ticker].targetshort)*settings[ticker].stop)
        pos[ticker].p='short'
    end
    if pos[ticker].targetshort>=curClose then
        newMessage(SPAM,ticker..' takeprofit for short >= current price, skipping trade')
        Logging.Log(log,ticker..':  takeprofit for short >= current price, skipping trade')
        pos[ticker].p='n'
        pos[ticker].targetshort=0
        state[ticker].prevlineup=state[ticker].curlineup
        pos[ticker].stopshort=0
        state[ticker].upwork=true 
        state[ticker].davaishort=false
        pos[ticker].qualshort=0
        return
    end
    --[[if pos[ticker].stopshort<=Graph.GetC(settings[ticker].tag,0).close then
        newMessage(SPAM,ticker..' stop for short <= current price, skipping trade')
        Logging.Log(log,ticker..':  stop for short <= current price, skipping trade')
        pos[ticker].p='n'
        pos[ticker].targetshort=0
        state[ticker].prevlineup=state[ticker].curlineup
        pos[ticker].stopshort=0
        state[ticker].upwork=true 
        state[ticker].davaishort=false
        pos[ticker].qualshort=0
        return
    end]]
    state[ticker].shortbr=upcur  
    if trading[ticker].enabled then
        local qt = getQuoteLevel2(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)           
        local bid = qt.bid[qt.bid_count+0].price
        local a,b,c = Trading.SendLimitOrder(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,"S",bid,trading[ticker].volume,Account,ClientCode)
        if a==false then
            newMessage(SPAM,c,3)
            is_run=false
        end             
    end
    state[ticker].scdt=Graph.GetC(settings[ticker].tag,0).datetime
    state[ticker].open=curClose
    StatOpen(ticker,curClose,'Продажа',state[ticker].speedup)   
    newMessage(SPAM,ticker..': сигнал в шорт, стоп: '..tostring(pos[ticker].stopshort)..', тейк: '..tostring(pos[ticker].targetshort)..', вход '..tostring(curClose))                         
    Logging.Log(log,ticker..': сигнал в шорт, стоп: '..tostring(pos[ticker].stopshort)..', тейк: '..tostring(pos[ticker].targetshort)..', вход '..curClose)
    Beep()
    Logging.TradeLog(tradelog,','..ticker..',Продажа,'..tostring(curClose)..',1,'..SysFunc.GetTime2()..','..tostring(state[ticker].speedup))
end

function updateTable(ticker)
    local row=table.indexof(tickers,ticker)
    --t2t:SetValue(row+row-1, "Тип", state[ticker].uptrend)
    t2t:SetValue(row+row-1, "Скорость", state[ticker].speedup)
    t2t:SetValue(row+row, "Скорость", state[ticker].speeddown)
    t2t:SetValue(row+row-1, "Знач", state[ticker].uptrendvalue)
    --t2t:SetValue(row+row, "Тип", state[ticker].downtrend)
    t2t:SetValue(row+row, "Знач", state[ticker].downtrendvalue)
    if pos[ticker].p=='long' then        
        t2t:SetValue(row+row, "Пробой", 'LONG') 
        t2t:SetValue(row+row, "Вход", state[ticker].open)
        t2t:SetValue(row+row, "Цель", pos[ticker].targetlong)
        t2t:SetValue(row+row, "Стоп", pos[ticker].stoplong)
        t2t:SetColor(row+row,"Пробой",10157978,nil,10157978)
        t2t:SetColor(row+row,"Вход",10157978,nil,10157978)
       -- t2t:SetColor(row+row,"Тип",10157978,nil,10157978)
        t2t:SetColor(row+row,"Тикер",10157978,nil,10157978)
        t2t:SetColor(row+row,"Цель",10157978,nil,10157978) 
        t2t:SetColor(row+row,"Стоп",10157978,nil,10157978) 
    elseif pos[ticker].p=='n' then
        if state[ticker].downtrend then
            if state[ticker].downwork then
                t2t:SetValue(row+row, "Пробой", "отработана")
            else
                t2t:SetValue(row+row, "Пробой", "не отработана")
            end
        else
            t2t:SetValue(row+row, "Пробой", "нет линии")
        end
        t2t:SetValue(row+row, "Цель", "")
        t2t:SetValue(row+row, "Стоп", "")
        t2t:SetColor(row+row,"Пробой") 
        --t2t:SetColor(row+row,"Тип")
        t2t:SetColor(row+row,"Тикер")
        t2t:SetValue(row+row, "Вход", "")
        t2t:SetColor(row+row,"Вход") 
        t2t:SetColor(row+row,"Цель") 
        t2t:SetColor(row+row,"Стоп")
    end 
    if pos[ticker].p=='short' then
        t2t:SetValue(row+row-1, "Пробой", 'SHORT') 
        t2t:SetValue(row+row-1, "Вход", state[ticker].open)  
        t2t:SetValue(row+row-1, "Цель", pos[ticker].targetshort)
        t2t:SetValue(row+row-1, "Стоп", pos[ticker].stopshort)
        t2t:SetColor(row+row-1,"Пробой",52479,nil,52479)         
        --t2t:SetColor(row+row-1,"Тип",52479,nil,52479)
        t2t:SetColor(row+row-1,"Тикер",52479,nil,52479)
        t2t:SetColor(row+row-1,"Вход",52479,nil,52479) 
        t2t:SetColor(row+row-1,"Цель",52479,nil,52479) 
        t2t:SetColor(row+row-1,"Стоп",52479,nil,52479) 
    elseif pos[ticker].p=='n' then
        if state[ticker].uptrend then
            if state[ticker].upwork then
                t2t:SetValue(row+row-1, "Пробой", "отработана")
            else
                t2t:SetValue(row+row-1, "Пробой", "не отработана")
            end
        else
            t2t:SetValue(row+row-1, "Пробой", "нет линии")
        end
        t2t:SetValue(row+row-1, "Цель", "")
        t2t:SetValue(row+row-1, "Стоп", "")
        t2t:SetColor(row+row-1,"Пробой") 
       -- t2t:SetColor(row+row-1,"Тип")
        t2t:SetColor(row+row-1,"Тикер")
        t2t:SetValue(row+row-1, "Вход", "")
        t2t:SetColor(row+row-1,"Цель") 
        t2t:SetColor(row+row-1,"Вход") 
        t2t:SetColor(row+row-1,"Стоп")
    end
    if state[ticker].davailong and state[ticker].downtrendvalue~=0 then
        t2t:SetColor(row+row,"Знач",10157978,nil,10157978) 
    else
        t2t:SetColor(row+row,"Знач")
    end
    if state[ticker].davaishort and state[ticker].uptrendvalue~=0 then
        t2t:SetColor(row+row-1,"Знач",52479,nil,52479) 
    else
        t2t:SetColor(row+row-1,"Знач")
    end                  
end

function flushState(ticker)
    state[ticker]={name=ticker.name,uptrend=false,uptrendvalue=0,upwork=false,downwork=false,downtrend=false,downtrendvalue=0,
                                    linebreakup=false,linebreakdown=false,curlineup={},prevlineup={},curlinedown={},
                                    prevlinedown={},davailong=false,davaishort=false,candleh=0,candled=0,candlem=0,speedup=0,speeddown=0,tf=0,lcdt=nil,scdt=nil,longbr=0,shortbr=0,profit=0,profitcheck=false}
end
initstop=false
function main()
    if debug==1 then
        NewInit()
        init=true
    end
    while not init do
        if isConnected()~=0 and SysFunc.CheckTime()=="T" and init==false then
            NewInit()
            init=true
            break
        end
        if initstop then
            break
        end
        sleep(1000)
    end	
    while is_run do
	    while isConnected()==0 do
	        sleep(1000)
	    end
        if debug==1 then
            for i=1,#tickers do          
                Monitor(tickers[i]) 
                updateTable(tickers[i])
                sleep(100)
                pointCheck(tickers[i],1) --смещаем точки, при появлении новой свечи   
            end 
        end 
        for i=1,#tickers do             
            if isConnected()~=0 and SysFunc.CheckTime()=="T" then
                if trading[tickers[i]].enabled then                 
                    MarginCheck()          
                end
                if settings[tickers[i]].profitcheck and not state[tickers[i]].profitcheck then
                    dayProfitCheck(tickers[i])
                end
                if Graph.GetC(settings[tickers[i]].tag,0)==0 then
                    sleep(1000)
                else
                    state[tickers[i]].candled=Graph.GetC(settings[tickers[i]].tag,0).datetime.day
                    state[tickers[i]].candleh=Graph.GetC(settings[tickers[i]].tag,0).datetime.hour
                    state[tickers[i]].candlem=Graph.GetC(settings[tickers[i]].tag,0).datetime.minute
                    if profitstop and settings[tickers[i]].profitcheck then                                                          
                        pointCheck(tickers[i],1) 
                        Monitor(tickers[i])
                        if state[tickers[i]].profitcheck~=true then
                            updateTable(tickers[i])                 
                        end
                    end
                    if not profitstop then                        
                        pointCheck(tickers[i],1) 
                        Monitor(tickers[i])              
                        updateTable(tickers[i])               
                    end    
                end                                 
            end
            if isConnected()~=0 and SysFunc.CheckTime()=="S" and settings[tickers[i]].close==true then            
                ClosePosition(tickers[i])
                state[tickers[i]].profit=0
            end
            table.save(pos,getScriptPath().."\\pos_fut.txt")
            table.save(state,getScriptPath().."\\state_fut.txt")  
        end        
        sleep(777)                   
	end		 
end

function dayProfitCheck(ticker)
    local row=table.indexof(tickers,ticker)
    local go=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'buydepo').param_value
    local step_price=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'steppricet').param_value
    local step=getParamEx(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,'SEC_PRICE_STEP').param_value
    local curprofit=state[ticker].profit
    local needprofit=profitday*(go/step_price)*step
    local needprofit2=(profitday+0.01)*(go/step_price)*step
    if curprofit>=needprofit2 and not state[ticker].profitcheck then
        if trading[ticker].enabled then
            ClosePosition(ticker)        
            trading[ticker].enabled=false
        end
        message(windowname..' '..ticker..' offline, profit= '..tostring(curprofit),1)
        state[ticker].profit=0
        Logging.Log(log,ticker..' offline, profit= '..tostring(curprofit))
        state[ticker].profitcheck=true
        t2t:SetValue(row+row, "Пробой", "OFFLINE")
        t2t:SetValue(row+row-1, "Пробой", "OFFLINE")
        t2t:SetColor(row+row-1,"Пробой",13882323,nil,13882323)    
        t2t:SetColor(row+row-1,"Тикер",13882323,nil,13882323)
        t2t:SetColor(row+row-1,"Вход",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Знач",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Цель",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Стоп",13882323,nil,13882323)
        t2t:SetColor(row+row,"Пробой",13882323,nil,13882323)    
        t2t:SetColor(row+row,"Тикер",13882323,nil,13882323)
        t2t:SetColor(row+row,"Вход",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Знач",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Цель",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Стоп",13882323,nil,13882323)
    elseif curprofit-fakezero[ticker]<=(-1)*needprofit and not state[ticker].profitcheck then
        if trading[ticker].enabled then
            ClosePosition(ticker)
            trading[ticker].enabled=false
        end
        message(windowname..' '..ticker..' offline, profit= '..tostring(curprofit),1)
        state[ticker].profit=0
        Logging.Log(log,ticker..' offline, profit= '..tostring(curprofit))
        state[ticker].profitcheck=true 
        t2t:SetValue(row+row, "Пробой", "OFFLINE")
        t2t:SetValue(row+row-1, "Пробой", "OFFLINE")
        t2t:SetColor(row+row-1,"Пробой",13882323,nil,13882323)    
        t2t:SetColor(row+row-1,"Тикер",13882323,nil,13882323)
        t2t:SetColor(row+row-1,"Вход",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Знач",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Цель",13882323,nil,13882323) 
        t2t:SetColor(row+row-1,"Стоп",13882323,nil,13882323)
        t2t:SetColor(row+row,"Пробой",13882323,nil,13882323)    
        t2t:SetColor(row+row,"Тикер",13882323,nil,13882323)
        t2t:SetColor(row+row,"Вход",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Знач",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Цель",13882323,nil,13882323) 
        t2t:SetColor(row+row,"Стоп",13882323,nil,13882323)     
    end     
end

function MarginCheck()
    for i=1,#tickers do
        local count=getNumberOf("futures_client_holding")
        for j=0,count-1, 1 do
            local p=getItem("futures_client_holding", j)
            --newMessage(SPAM,SysFunc.table2string(p))
            if p.seccode==settings[tickers[i]].name then
                if p.varmargin>=trading[tickers[i]].margintake and trading[tickers[i]].enabled then
                    ClosePosition(tickers[i])
                    newMessage(SPAM,tickers[i]..' trading off')
                    Logging.Log(log,tickers[i]..': trading off due to margin>'..tostring(trading[tickers[i]].margintake))
                    trading[tickers[i]].enabled=false   
                elseif p.varmargin<=trading[tickers[i]].marginstop and trading[tickers[i]].enabled then
                    ClosePosition(tickers[i])
                    newMessage(SPAM,tickers[i]..' trading off')
                    Logging.Log(log,tickers[i]..': trading off due to margin<'..tostring(trading[tickers[i]].marginstop))
                    trading[tickers[i]].enabled=false                
                end
            end
        end
    end
end

function ClosePosition(ticker)
    local curClose=Graph.GetC(settings[ticker].tag,0).close 
    local net=0
    local count=getNumberOf("futures_client_holding")
    for j=0,count-1, 1 do
        local p=getItem("futures_client_holding", j)
        --newMessage(SPAM,SysFunc.table2string(p))
        if p.seccode==settings[ticker].name then
            net=p.totalnet
        end
    end        
        if pos[ticker].p=='long' then
            if trading[ticker].enabled and net~=0 then
                Trading.KillAllOrders(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)
                local a,b=Trading.KillAllStops(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)                    
                local qt = getQuoteLevel2(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)           
                local bid = qt.bid[qt.bid_count+0].price
                local a,b,c = Trading.SendLimitOrder(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,"S",bid,trading[ticker].volume,Account,ClientCode)
                if a==false then
                    newMessage(SPAM,c,3)
                    is_run=false
                end  
                pos[ticker].tp=false     
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+curClose-state[ticker].open
            end
            newMessage(SPAM,ticker..': закрыл лонг, тп: '..tostring(pos[ticker].targetlong)..', цена: '..tostring(curClose))
            Logging.Log(log,ticker..': закрыл лонг, тп: '..tostring(pos[ticker].targetlong)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Продажа')
            Logging.TradeLog(tradelog,','..ticker..',Продажа,'..tostring(curClose)..',1,'..SysFunc.GetTime2())
            pos[ticker].p='n'
            pos[ticker].targetlong=0 --новых целей нет            
            state[ticker].prevlinedown=state[ticker].curlinedown  
            pos[ticker].stoplong=0
            state[ticker].downwork=true --линия отработала
            state[ticker].davailong=false
            pos[ticker].quallong=0
        elseif pos[ticker].p=='short' then
            if trading[ticker].enabled and net~=0 then
                Trading.KillAllOrders(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)
                local a,b=Trading.KillAllStops(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)                    
                local qt = getQuoteLevel2(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name)           
                local offer = qt.offer[1].price
                local a,b,c = Trading.SendLimitOrder(SysFunc.getSecurityClass(settings[ticker].name),settings[ticker].name,"B",offer,trading[ticker].volume,Account,ClientCode)
                if a==false then
                    newMessage(SPAM,c,3)
                    is_run=false
                end                          
                pos[ticker].tp=false     
            end
            if settings[ticker].profitcheck then
                state[ticker].profit=state[ticker].profit+state[ticker].open-curClose
            end
            newMessage(SPAM,ticker..': закрыл шорт, тп: '..tostring(pos[ticker].targetshort)..', цена: '..tostring(curClose))
            Logging.Log(log,ticker..': закрыл шорт, тп: '..tostring(pos[ticker].targetshort)..', цена: '..tostring(curClose))
            StatClose(ticker,curClose,'Купля')
            Logging.TradeLog(tradelog,','..ticker..',Купля,'..tostring(curClose)..',1,'..SysFunc.GetTime2())
            pos[ticker].p='n'
            pos[ticker].targetshort=0
            state[ticker].prevlineup=state[ticker].curlineup
            pos[ticker].stopshort=0
            state[ticker].upwork=true 
            state[ticker].davaishort=false
            pos[ticker].qualshort=0
        end
end

function OnStop()
    if init then
        for i=1,#tickers do
            state[tickers[i]].profit=0
            state[tickers[i]].profitcheck=false
        end
        table.save(state,getScriptPath().."\\state_fut.txt")
        table.save(pos,getScriptPath().."\\pos_fut.txt")
        t2t:delete()
        is_run = false
    else
        is_run = false
    end
end

function OnTrade(trade)
    for i=1,#tickers do 
        if trade.seccode==settings[tickers[i]].name and trading[tickers[i]].enabled then --находим по какому тикеру прошла сделка
            if SysFunc.orderflags2table(trade.flags).operation=='B' then --смотрим направление
                if pos[tickers[i]].p=='long' then --если по текущему тикеру лонг, то выставляем тп
                    local a,b,c = Trading.SendTPSLOrder(SysFunc.getSecurityClass(settings[tickers[i]].name),settings[tickers[i]].name,"S",trade.price,pos[tickers[i]].targetlong,pos[tickers[i]].stoplong,trading[tickers[i]].maxoffset,trading[tickers[i]].defspread,trade.qty,Account,ClientCode)                                                                                        
                    pos[tickers[i]].tp=true
                    if a==false then
                        newMessage(SPAM,c,3)
                        is_run=false
                    end
                end --иначе нек делаем ничего, во избежание конфликта
            end
            if SysFunc.orderflags2table(trade.flags).operation=='S' then
                if pos[tickers[i]].p=='short' then
                    local a,b,c = Trading.SendTPSLOrder(SysFunc.getSecurityClass(settings[tickers[i]].name),settings[tickers[i]].name,"B",trade.price,pos[tickers[i]].targetshort,pos[tickers[i]].stopshort,trading[tickers[i]].maxoffset,trading[tickers[i]].defspread,trade.qty,Account,ClientCode)                                                                                        
                    pos[tickers[i]].tp=true
                    if a==false then
                        newMessage(SPAM,c,3)
                        is_run=false
                    end
                end --иначе нам похуй вроде
            end
        end
    end
end
   
function table.save(tbl,filename)
   local f,err = io.open(filename,"w")
   if not f then
      return nil,err
   end
   f:write(table.tostring(tbl))
   f:close()
   return true
end
function table.read(filename)
   local f,err = io.open(filename,"r")
   if not f then
      return nil,err
   end
   local tbl = assert(loadstring("return " .. f:read("*a")))
   f:close()
   return tbl()
end
function table.val_to_str ( v )
   if "string" == type( v ) then
      v = string.gsub( v, "\n", "\\n" )
      if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
         return "'" .. v .. "'"
      end
      return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
   end
   return "table" == type( v ) and table.tostring( v ) or tostring( v )
end
function table.key_to_str ( k )
   if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
      return k
   end
   return "[" .. table.val_to_str( k ) .. "]"
end
function table.tostring( tbl )
   local result, done = {}, {}
   for k, v in ipairs( tbl ) do
      table.insert( result, table.val_to_str( v ) )
      done[ k ] = true
   end
   for k, v in pairs( tbl ) do
      if not done[ k ] then
         table.insert( result, table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
      end
   end
   return "{" .. table.concat( result, "," ) .. "}"
end
function table.getkey(myTable,myKeyNumber) -- get the key variable in a certain "position" named table (fake indexing)
    numKeys = 0
    for k,v in pairs(myTable) do
        if myKeyNumber == numKeys then return k end
        numKeys = numKeys + 1
    end
end
function existsFile(path) --проверка существует ли файл    
    local st, f = pcall(io.open, path)
    if st and f then
        f:close()
        return true
    else
	    return false
    end 
end
function table.indexof(t,val)
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end
function round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end
function tableEventHandler(t_id,msg,par1,par2)--table events    
    if msg==QTABLE_LBUTTONDOWN then
        if par1%2==0 then
            local index=par1/2
            if autodraw then  
            SysFunc.GetCandleTime(settings[tickers[index]].tag,1)
            if state[tickers[index]].curlinedown.y1~=nil then  
            Graph.addLabel(settings[tickers[index]].tag,"",getScriptPath().."\\Img\\down.jpg",tostring(state[tickers[index]].curlinedown.y1),SysFunc.GetCandleDate(settings[tickers[index]].tag,state[tickers[index]].curlinedown.x1),SysFunc.GetCandleTime(settings[tickers[index]].tag,state[tickers[index]].curlinedown.x1),'нисходящая точка 1',"TOP")            
            Graph.addLabel(settings[tickers[index]].tag,"",getScriptPath().."\\Img\\down.jpg",tostring(state[tickers[index]].curlinedown.y2),SysFunc.GetCandleDate(settings[tickers[index]].tag,state[tickers[index]].curlinedown.x2),SysFunc.GetCandleTime(settings[tickers[index]].tag,state[tickers[index]].curlinedown.x2),'нисходящая точка 2',"TOP")                        
            end
            end
            message(tickers[index]..' нисходящая линия: ('..tostring(state[tickers[index]].curlinedown.x1)..';'..tostring(state[tickers[index]].curlinedown.y1)..') и ('..tostring(state[tickers[index]].curlinedown.x2)..';'..tostring(state[tickers[index]].curlinedown.y2)..')',1)    
        else
            local index=(par1+1)/2
            if autodraw then
            SysFunc.GetCandleTime(settings[tickers[index]].tag,1)
            if state[tickers[index]].curlineup.y1~=nil then
            Graph.addLabel(settings[tickers[index]].tag,"",getScriptPath().."\\Img\\up.jpg",tostring(state[tickers[index]].curlineup.y1),SysFunc.GetCandleDate(settings[tickers[index]].tag,state[tickers[index]].curlineup.x1),SysFunc.GetCandleTime(settings[tickers[index]].tag,state[tickers[index]].curlineup.x1),'восходящая точка 1',"BOTTOM")            
            Graph.addLabel(settings[tickers[index]].tag,"",getScriptPath().."\\Img\\up.jpg",tostring(state[tickers[index]].curlineup.y2),SysFunc.GetCandleDate(settings[tickers[index]].tag,state[tickers[index]].curlineup.x2),SysFunc.GetCandleTime(settings[tickers[index]].tag,state[tickers[index]].curlineup.x2),'восходящая точка 2',"BOTTOM")            
            end
            end
            message(tickers[index]..' восходящая линия: ('..tostring(state[tickers[index]].curlineup.x1)..';'..tostring(state[tickers[index]].curlineup.y1)..') и ('..tostring(state[tickers[index]].curlineup.x2)..';'..tostring(state[tickers[index]].curlineup.y2)..')',1)    
        end
    end  
    if msg==QTABLE_MBUTTONDOWN and autodraw then    
        if par1%2==0 then
            local index=par1/2
            Graph.delLabel(settings[tickers[index]].tag)
        else
            local index=(par1+1)/2
            Graph.delLabel(settings[tickers[index]].tag)
        end
    end
    if msg==QTABLE_MBUTTONDBLCLK then
        if par1%2==0 then
            local index=(par1)/2 
            ClosePosition(tickers[index])
        else
            local index=(par1+1)/2
            ClosePosition(tickers[index])
        end
    end        
end
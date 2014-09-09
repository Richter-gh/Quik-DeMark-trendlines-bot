
tickers={'RI_1h','RI_1h_1','RI_1h_2','GZ_1h','GZ_1h_1','GZ_1h_2','SR_1h','SR_1h_1','SR_1h_2','Si_1h','Eu_1h'}

debug=0-- для включения без подключения к серверу. игнорируется текущее время  

windowname='Fut_h_2 v1.5.0.1'

autodraw=true --при false совместимо с 6.12, при true автоматически перерисовывает линии при появлении\изменении

Account='J700532'

ClientCode='J700532'

SPAM=false

profitday=0.01--in %: stops trading when achieved. only for intraday plz

profitstop=true

Sound=true --makes BEEP on every trade
--	memo        
--mincandle - радиус поиска тд точки
--search - радиус поиска свечи для выставления тп
--name - название инструмента - как он отображается в квиковских таблицах
--tag - тэг графика
--
settings['SR_1h']={name='SRU4',tag='SR_1h',mincandle=3,search=3,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['GZ_1h']={name='GZU4',tag='GZ_1h',mincandle=3,search=3,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['GZ_1h_2']={name='GZU4',tag='GZ_1h',mincandle=2,search=2,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['RI_1h_2']={name='RIU4',tag='RI_1h',mincandle=2,search=2,stop=0.5,tp=500,tpmax=600,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['RI_1h']={name='RIU4',tag='RI_1h',mincandle=3,search=3,stop=0.5,tp=500,tpmax=600,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['Si_1h']={name='SiU4',tag='Si_1h',mincandle=3,search=3,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['Eu_1h']={name='EuU4',tag='Eu_1h',mincandle=3,search=3,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['SR_1h_2']={name='SRU4',tag='SR_1h',mincandle=2,search=1,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['GZ_1h_1']={name='GZU4',tag='GZ_1h',mincandle=1,search=1,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['RI_1h_1']={name='RIU4',tag='RI_1h',mincandle=1,search=1,stop=0.5,tp=500,tpmax=600,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}
settings['SR_1h_1']={name='SRU4',tag='SR_1h',mincandle=1,search=1,stop=0.5,tp=50,tpmax=60,linecheck=true,speed=0,br='cur',close=true,falsebreak=false,profitcheck=true}

trading['SR_1h']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['GZ_1h']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['GZ_1h_2']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['RI_1h_2']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['RI_1h']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['Si_1h']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['Eu_1h']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['SR_1h_2']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['GZ_1h_1']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['RI_1h_1']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
trading['SR_1h_1']={enabled=false,volume=1,maxoffset=0,defspread=0,margintake=200,marginstop=-100}
-------------------------------------------/settings

-- SETTINGS DESCRIPTION
--name - название инструмента - как он отображается в квиковских таблицах

--tag - тэг графика	
        
--mincandle - радиус поиска тд точки

--search - радиус поиска свечи для выставления тп и стопов

--stop - проценты от тп для выставления стопа, 1-100, 0.5-50 итд

--tp - фиксированное значение тп, в этом случае стоп выставляется на лой\хай в радиусе search
--если не нужен фиксированный тп, выставить 0

--linecheck - проверка линий на ебловатость

--speedcheck - проверка на скорость, если она >=\<= заданного значения в speed, то заходим в сделку
--скорости везде берутся по модулю

--br - проверка пробоя: prev - на предыдущем фрейме, cur - на текущем(для дневных, например)

--close - закрывать ли позиции на клирингах и в конце дня

--falsebreak - проверка на возвращение за линию после пробоя
--   
--все что ниже по идее трогать не надо
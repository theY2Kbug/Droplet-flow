clear;
clc;
x=0;
y=0;  
dia = 0.95;
Lambdamax = 10*dia;
ll = 6.1; %Length of upper/longer channel
ls = 5; %Length of lower/shorter channel
ld = ((Lambdamax/ls)-1-(ls/ll))*ll; 
fprintf('Ld=%f\n',ld);
lambda = Lambdamax*0.345;
fprintf('input speed=%f\n',lambda);
Qw = 0;
Qo = 0;
while 1
    Qw = input('ENTER FLOW RATE OF WATER (cm^3/s)');
    Qo = input('ENTER FLOW RATE OF OIL (cm^3/s)');
    Critcap = (0.027*pi)*(1+(1.4*Qw/Qo))*(((((1/pi) + (1.4*Qw)/(pi*Qo))^(-2/3))-1)^2);
    if (Critcap >= 1e-4) &&  (Critcap <= 1e-2)
        fprintf('Critical Capillary number=%f\n',Critcap);
        break;
    else
        disp('CRITICAL CAPILLARY NUMBER REACHED. RE-ENTER VALUES AGAIN!');
        fprintf('Critical Capillary number=%f\n',Critcap);
        pause(2)
    end
end

Qi = Qo + Qw;
beta = lambda*(pi*dia*dia/4)/Qi;
fprintf('beta=%f\n',beta);
x_fixed_left = [0 40];
y_fixed_left = [0 0];
x_fixed_right = [42 100];
y_fixed_right = [0 0];
x_fixed = [40 40 42 42]; 
y_upper = [0 2.05 2.05 0];
y_lower = [0 -1.5 -1.5 0];
drop_count = floor(40/lambda);
disp(drop_count+1);

f1 = figure('WindowState','maximized');
pause(1)
f1.Position;
ax1=axes('Parent',f1);
xlim([37 45]);
ylim([-5 5]);
grid(ax1,'on');
hold(ax1,'on');


plot(ax1,x_fixed_left,y_fixed_left,'color','k','linewidth',3);
plot(ax1,x_fixed_right,y_fixed_right,'color','k','linewidth',3);
plot(ax1,x_fixed,y_upper,'color','k','linewidth',3);
plot(ax1,x_fixed,y_lower,'color','k','linewidth',3);
plot(ax1,x, y, 'mo','markerfacecolor','y');
for i=1 : 1 : drop_count
    if(mod(i,2)==0)
        plot(ax1,i*lambda, y, 'mo','markerfacecolor','y','MarkerSize',15);
    else
        plot(ax1,i*lambda, y, 'bo','markerfacecolor','g','MarkerSize',15);
    end
end


t = timer;
t.StartFcn = {@initTimer,drop_count};
t.TimerFcn = { @fluflow,lambda,beta,ll,ls,ld,Qi,ax1};
t.StopFcn = @(~,~)delete(t);
t.Period = 2;
t.TasksToExecute = 35;
t.ExecutionMode = 'fixedSpacing';
t.UserData = struct('k',[],'longercount',[],'shortercount',[],'temp',[],'temptime',[],'Vlong',[],'Vshort',[],'Qlong',[],'Qshort',[],'Rlong',[],'Rshort',[],'flag',[],'temptime_min',[],'global_time',[],'tempt',[],'tempt1',[]);
start(t)

function initTimer(obj, ~,count)
    obj.UserData = setfield(obj.UserData, 'k', count+1);
    obj.UserData = setfield(obj.UserData, 'longercount', 0);
    obj.UserData = setfield(obj.UserData, 'shortercount', 0);
    obj.UserData = setfield(obj.UserData, 'temp', 0);
    obj.UserData = setfield(obj.UserData, 'tempt', 0);
    obj.UserData = setfield(obj.UserData, 'tempt1', 0);
    obj.UserData = setfield(obj.UserData, 'temptime', 0);
    obj.UserData = setfield(obj.UserData, 'temptime_min', 0);
    obj.UserData = setfield(obj.UserData, 'Rl', 0);
    obj.UserData = setfield(obj.UserData, 'Rs', 0);
    obj.UserData = setfield(obj.UserData, 'Vlong', 0);
    obj.UserData = setfield(obj.UserData, 'Vshort', 0);
    obj.UserData = setfield(obj.UserData, 'flag', 0);
    obj.UserData = setfield(obj.UserData, 'global_time', 0);
    disp('initialised')
end

function fluflow(obj,~,input_speed,b,lenlong,lenshort,ld,Qinput,ax1)
    obj.UserData = setfield(obj.UserData,'temptime_min',100);
    obj.UserData = setfield(obj.UserData,'temptime',0);
    grid(ax1,'on');
    hold(ax1,'on');
    h = findobj(ax1,'Type','line');
    A = zeros(12,1);
    status = strings(12,1);
    for f = 1 : 1.0 : getfield(obj.UserData,'k')
        prevX = get(h(f),'XData');
        prevY = get(h(f),'YData'); 
        
        if((prevX>=0) && (prevX<=40) &&(prevY==0))
            obj.UserData = setfield(obj.UserData,'temptime',(40-prevX)/input_speed);
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='enter';
        elseif((prevX == 40)&&(prevY>0) && (prevY<2.5))
            obj.UserData = setfield(obj.UserData, 'temptime', (2.05-prevY+2.05+2)/getfield(obj.UserData, 'Vlong'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        elseif((prevX > 40)&&(prevY==2.05)&&(prevX<42))
            obj.UserData = setfield(obj.UserData, 'temptime', (42-prevX+2.05)/getfield(obj.UserData, 'Vlong'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        elseif((prevX == 42)&&(prevY<2.05)&&(prevY>0))
            obj.UserData = setfield(obj.UserData, 'temptime', prevY/getfield(obj.UserData, 'Vlong'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        elseif((prevX == 40)&&(prevY<0)&&(prevY>-1.5))
            obj.UserData = setfield(obj.UserData, 'temptime', (1.5+prevY+2+1.5)/getfield(obj.UserData, 'Vshort'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        elseif((prevX>40)&&(prevY==-1.5)&&(prevX<42))
            obj.UserData = setfield(obj.UserData, 'temptime', (1.5+42-prevX)/getfield(obj.UserData, 'Vshort'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        elseif((prevX==42)&&(prevY<0)&&(prevY>-1.5))
            disp(getfield(obj.UserData, 'Vshort'))
            obj.UserData = setfield(obj.UserData, 'temptime', (-1*prevY)/getfield(obj.UserData, 'Vshort'));
            if(getfield(obj.UserData, 'temptime')<getfield(obj.UserData, 'temptime_min'))
                obj.UserData = setfield(obj.UserData,'temptime_min',getfield(obj.UserData, 'temptime'));
            end 
            A(f) = getfield(obj.UserData, 'temptime');
            status(f)='exit';
        else
            A(f) = NaN;
            status(f)='exited';
        end
    end
    T1 = table(A,status);
    disp(T1)
    fprintf('min time = %f \n',getfield(obj.UserData,'temptime_min'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    obj.UserData = setfield(obj.UserData,'tempt',0.0001*getfield(obj.UserData,'temptime_min'));
    obj.UserData = setfield(obj.UserData,'temptime',1.0001*getfield(obj.UserData,'temptime_min'));
    obj.UserData = setfield(obj.UserData, 'Rlong', lenlong+(getfield(obj.UserData,'longercount')*ld));
    obj.UserData = setfield(obj.UserData, 'Rshort', lenshort+(getfield(obj.UserData,'shortercount')*ld));
    obj.UserData = setfield(obj.UserData, 'Qshort', Qinput/((getfield(obj.UserData,'Rshort')/getfield(obj.UserData,'Rlong'))+1));
    obj.UserData = setfield(obj.UserData, 'Qlong', Qinput-getfield(obj.UserData,'Qshort'));            
    obj.UserData = setfield(obj.UserData, 'Vshort', (b*getfield(obj.UserData,'Qshort'))/(pi*0.95*0.95/4));
    obj.UserData = setfield(obj.UserData, 'Vlong', (b*getfield(obj.UserData,'Qlong'))/(pi*0.95*0.95/4));
    obj.UserData = setfield(obj.UserData,'global_time',getfield(obj.UserData,'temptime_min')+getfield(obj.UserData,'global_time'));
    for f = 1 : 1.0 : getfield(obj.UserData,'k')
        prevX = get(h(f),'XData');
        prevY = get(h(f),'YData');
        if((prevX>=0) && (prevX+(input_speed*getfield(obj.UserData,'temptime'))<40) &&(prevY==0))
            set(h(f),'XData',prevX+(input_speed*getfield(obj.UserData,'temptime')))
            set(h(f),'YData',prevY)
        elseif(((prevX+(input_speed*getfield(obj.UserData,'temptime')))>40) && (prevY == 0) && (prevX<40))
            if(getfield(obj.UserData,'Rshort')<getfield(obj.UserData,'Rlong'))
                obj.UserData = setfield(obj.UserData, 'temp', getfield(obj.UserData, 'Vshort')*getfield(obj.UserData, 'tempt'));
                obj.UserData = setfield(obj.UserData, 'shortercount', getfield(obj.UserData, 'shortercount')+1);
                if (getfield(obj.UserData,'temp')<=1.5)
                    set(h(f),'XData',40);
                    set(h(f),'YData',-1*getfield(obj.UserData, 'temp'));
                elseif((getfield(obj.UserData,'temp')<=3.5) && (getfield(obj.UserData,'temp')>1.5))
                    set(h(f),'XData',40+getfield(obj.UserData,'temp')-1.5);
                    set(h(f),'YData',-1.5);   
                elseif((getfield(obj.UserData,'temp')>3.5)&&(getfield(obj.UserData,'temp')<=5))
                    set(h(f),'XData',42);
                    set(h(f),'YData',-1.5+getfield(obj.UserData, 'temp')-3.5);
                end
                continue;   
            elseif(getfield(obj.UserData,'Rshort')>getfield(obj.UserData,'Rlong'))
                obj.UserData = setfield(obj.UserData, 'temp', getfield(obj.UserData, 'Vlong')*getfield(obj.UserData, 'tempt'));
                obj.UserData = setfield(obj.UserData, 'longercount', getfield(obj.UserData, 'longercount')+1);
                if (getfield(obj.UserData,'temp')<=2.05)
                    set(h(f),'XData',40)
                    set(h(f),'YData',getfield(obj.UserData, 'temp'))
                elseif((getfield(obj.UserData,'temp')<=4.05) && (getfield(obj.UserData,'temp')>2.05))
                    set(h(f),'XData',40+getfield(obj.UserData, 'temp')-2.05)
                    set(h(f),'YData',2.05)
                elseif((getfield(obj.UserData,'temp')<=6.1) && (getfield(obj.UserData,'temp')>4.05))
                    set(h(f),'XData',42)
                    set(h(f),'YData',2.05-getfield(obj.UserData, 'temp')-4.05)
                end
                continue;
            end
        end
            
        if((prevX == 40)&&(prevY>0) && (prevY<2.5))
            obj.UserData = setfield(obj.UserData, 'temp', (getfield(obj.UserData, 'Vlong')*getfield(obj.UserData, 'temptime'))+prevY);
            if(getfield(obj.UserData, 'temp')<=2.05)
                set(h(f),'XData',40);
                set(h(f),'YData',getfield(obj.UserData,'temp'));
            elseif((getfield(obj.UserData,'temp')<=4.05) && (getfield(obj.UserData,'temp')>2.05))
                set(h(f),'XData',40+getfield(obj.UserData, 'temp')-2.05)
                set(h(f),'YData',2.05)
            elseif((getfield(obj.UserData,'temp')<=6.1) && (getfield(obj.UserData,'temp')>4.05))
                set(h(f),'XData',42)
                set(h(f),'YData',2.05-getfield(obj.UserData, 'temp')-4.05)
            elseif((getfield(obj.UserData,'temp')>6.1))
                obj.UserData = setfield(obj.UserData, 'tempt1', (2.05-prevX+4.05)/getfield(obj.UserData, 'Vlong'));
                obj.UserData = setfield(obj.UserData, 'longercount', getfield(obj.UserData, 'longercount')-1);
                set(h(f),'XData',input_speed*(getfield(obj.UserData, 'temptime')-getfield(obj.UserData, 'tempt1')))
                set(h(f),'YData',0)
            end
        elseif((prevX > 40)&&(prevY==2.05)&&(prevX<42))
            obj.UserData = setfield(obj.UserData, 'temp', prevX+(getfield(obj.UserData, 'Vlong')*getfield(obj.UserData,'temptime')));
            if(getfield(obj.UserData, 'temp')<=42)
                set(h(f),'XData',getfield(obj.UserData, 'temp'))
                set(h(f),'YData',2.05)
            elseif(getfield(obj.UserData, 'temp')>42 && getfield(obj.UserData, 'temp')<=44.05)
                obj.UserData = setfield(obj.UserData, 'temp', (getfield(obj.UserData, 'Vlong')*getfield(obj.UserData,'temptime'))-(42-prevX));
                set(h(f),'XData',42)
                set(h(f),'YData',2.05-(getfield(obj.UserData, 'temp')))                    
            elseif(getfield(obj.UserData, 'temp')>44.05)
                obj.UserData = setfield(obj.UserData, 'temp', 2.05+42-prevX);
                obj.UserData = setfield(obj.UserData, 'tempt1', getfield(obj.UserData, 'temp')/getfield(obj.UserData, 'Vlong'));
                obj.UserData = setfield(obj.UserData, 'longercount', getfield(obj.UserData, 'longercount')-1);
                set(h(f),'XData',42+((getfield(obj.UserData,'temptime')-getfield(obj.UserData,'tempt1'))*input_speed))
                set(h(f),'YData',0)
            end
        elseif((prevX == 42)&&(prevY<2.05)&&(prevY>0))
            obj.UserData = setfield(obj.UserData, 'temp', prevY-(getfield(obj.UserData, 'Vlong')*getfield(obj.UserData,'temptime')));
            if(getfield(obj.UserData,'temp')>=0)
                set(h(f),'XData',42)
                set(h(f),'YData',getfield(obj.UserData, 'temp'))
            elseif(getfield(obj.UserData,'temp')<0)
                obj.UserData = setfield(obj.UserData, 'tempt1', prevY/getfield(obj.UserData,'Vlong'));
                set(h(f),'XData',42+((getfield(obj.UserData,'temptime')-getfield(obj.UserData,'tempt1'))*input_speed))
                set(h(f),'YData',0)
                obj.UserData = setfield(obj.UserData, 'longercount', getfield(obj.UserData, 'longercount')-1);
            end
        elseif((prevX == 40)&&(prevY<0)&&(prevY>-1.5))
            obj.UserData = setfield(obj.UserData,'temp',(-1*prevY)+(getfield(obj.UserData,'Vshort')*getfield(obj.UserData,'temptime')));
            if(getfield(obj.UserData,'temp')<=1.5)
                set(h(f),'XData',40)
                set(h(f),'YData',-1*getfield(obj.UserData, 'temp'))
            elseif(getfield(obj.UserData,'temp')>1.5 && getfield(obj.UserData,'temp')<=3.5)
                set(h(f),'XData',40+getfield(obj.UserData,'temp')-1.5);
                set(h(f),'YData',-1.5);
            elseif(getfield(obj.UserData,'temp')>3.5 && getfield(obj.UserData,'temp')<=5.0)
                set(h(f),'XData',42);
                set(h(f),'YData',-1.5+getfield(obj.UserData,'temp')-3.5);
            elseif(getfield(obj.UserData,'temp')>5.0)
                obj.UserData = setfield(obj.UserData, 'tempt1', (5+prevY)/getfield(obj.UserData,'Vshort'));
                set(h(f),'XData',42+((getfield(obj.UserData,'temptime')-getfield(obj.UserData,'tempt1'))*input_speed));
                set(h(f),'YData',0);
                obj.UserData = setfield(obj.UserData, 'shortercount', getfield(obj.UserData, 'shortercount')-1);
            end
        elseif((prevX>40)&&(prevY==-1.5)&&(prevX<42))
            obj.UserData = setfield(obj.UserData, 'temp', prevX+(getfield(obj.UserData,'Vshort')*getfield(obj.UserData,'temptime')));
            if(getfield(obj.UserData, 'temp')<=42)
                set(h(f),'XData',getfield(obj.UserData, 'temp'))
                set(h(f),'YData',-1.5)
            elseif(getfield(obj.UserData, 'temp')>42 && getfield(obj.UserData, 'temp')<=43.5)
                set(h(f),'XData',42)
                set(h(f),'YData',getfield(obj.UserData, 'temp')-42-1.5)                    
            elseif(getfield(obj.UserData, 'temp')>43.5)
                obj.UserData = setfield(obj.UserData, 'tempt1',(1.5+42-prevX)/getfield(obj.UserData, 'Vshort'));
                obj.UserData = setfield(obj.UserData, 'shortercount', getfield(obj.UserData, 'shortercount')-1);
                set(h(f),'XData',42+((getfield(obj.UserData,'temptime')-getfield(obj.UserData,'tempt1'))*input_speed));
                set(h(f),'YData',0)
            end
        elseif((prevX == 42)&&(prevY<0)&&(prevY>-1.5))
            obj.UserData = setfield(obj.UserData, 'temp', prevY+(getfield(obj.UserData,'Vshort')*getfield(obj.UserData,'temptime')));
            if(getfield(obj.UserData,'temp')<=0)
                set(h(f),'XData',42)
                set(h(f),'YData',getfield(obj.UserData, 'temp'))
            elseif(getfield(obj.UserData,'temp')>0)
                obj.UserData = setfield(obj.UserData, 'tempt1', (-1*prevY)/getfield(obj.UserData,'Vshort'));
                set(h(f),'XData',42+((getfield(obj.UserData,'temptime')-getfield(obj.UserData,'tempt1'))*input_speed));
                set(h(f),'YData',0)
                obj.UserData = setfield(obj.UserData, 'shortercount', getfield(obj.UserData, 'shortercount')-1);
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif((prevX>=42)&&(prevY==0))
            if(prevX+input_speed<=100)
                set(h(f),'XData',prevX+(input_speed*getfield(obj.UserData,'temptime')));
                set(h(f),'YData',prevY);
            else
                set(h(f),'XData',NaN);
                set(h(f),'YData',NaN);
                obj.UserData = setfield(obj.UserData, 'k', getfield(obj.UserData, 'k')-1);
                break
            end            
        end
    end
    hold off;
end


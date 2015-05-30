function MovToPos_zjs(Movh1,Pos,resolution)

Nk=20;

SetPosOutput(Movh1,0,Pos);
pause(0.2);
Pos2=Pos;
for k=1:Nk

    [Dummy P1]=Movh1.GetPosOutput(0,0);
    pause(0.1);
    stepsize=Pos-P1;
    if abs(stepsize)>resolution
        Pos2=Pos2+(stepsize);
        if Pos2<=0
            Pos2 = 0.001;
        end
%         disp(['Pos2: ' num2str(Pos2)]);
%         display('I');
        if Pos2>=460 || Pos2<=0
            display('Error in MovToPos_zjs. The positon is out of range [0 460].');
            Movh1.StopCtrl;
            delete(Movh1);
            break;
        else
            if Pos2<=0
                Pos2 = 0;
            end
        end
%         disp(['Pos2: ' num2str(Pos2)]);
        SetPosOutput(Movh1,0,Pos2);
        pause(0.1);
    else
        return;
    end

end
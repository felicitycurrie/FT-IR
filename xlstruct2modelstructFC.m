function [M] = xlstruct2modelstructFC(XX,class,label,colour,mask)

if ~any(strcmp(fieldnames(XX),class))
    error(['no such field name: ',class]);
end
if ~any(strcmp(fieldnames(XX),label))
    error(['no such field name: ',label]);
end
if ~any(strcmp(fieldnames(XX),colour))
    error(['no such field name: ',colour]);
end


if ~any(strcmp(fieldnames(XX),mask))
    error(['no such field name: ',mask]);
end

Mask = [XX.(mask)]';

if any(Mask>2)
    error(['your mask file should only contain zeros, ones, or twos - dufus!. Mask name:',mask]);
end

ZZ = XX(Mask == 1);
YY = XX(Mask == 0);

if isa(XX(1).(class),'char')
    temp = {ZZ.(class)}';
    M.Class1 = class2num(temp);
    temp = {YY.(class)}';
    M.Class2 = class2num(temp);
else
    M.Class1 = [ZZ.(class)]';
    M.Class2 = [YY.(class)]';
end

if isa(XX(1).(label),'char')
    M.Label1 = {ZZ.(label)}';
    M.Label2 = {YY.(label)}';
else
    M.Label1 = cellstr(num2str([ZZ.(label)]'));
    M.Label2 = cellstr(num2str([YY.(label)]'));    
end

if isa(XX(1).(colour),'char')
    temp = {ZZ.(colour)}';
    M.Colour1 = class2num(temp);
    temp = {YY.(colour)}';
    M.Colour2 = class2num(temp);
else
    M.Colour1 = [ZZ.(colour)]';
    M.Colour2 = [YY.(colour)]';
end

M.X1 = cell2mat({ZZ.X}');
M.X2 = cell2mat({YY.X}');

M.UT = ZZ(1).Xlabel;
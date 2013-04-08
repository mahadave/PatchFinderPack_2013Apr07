s = size(data,1);

d=2;
n=length(x);
sigma=((n*var(x)+n*var(y))/(n+n))^0.5;
h=sigma*(4/(d+2))^(1/(d+4))*(n^(-1/(d+4)));



[gx gy]=meshgrid(size(data,1),size(data,2));

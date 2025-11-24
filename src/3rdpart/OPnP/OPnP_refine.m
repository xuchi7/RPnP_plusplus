function [R0 t0 error0 flag] = OPnP_refine(R,t,U,u)

R0 = []; t0 = []; error0 = []; flag = 1;
    
n = size(U,2);

%homogeneous coordinate
if size(u,1) > 2
    u = u(1:2,:);
end

%3D points after translation to centroid
Ucent = mean(U,2);
Um = U - repmat(Ucent,1,n);
xm = Um(1,:)'; ym = Um(2,:)'; zm = Um(3,:)';
x = U(1,:)'; y = U(2,:)'; z = U(3,:)';
u1 = u(1,:)'; v1 = u(2,:)';


%construct matrix N: 2n*11
N = zeros(2*n,11);
N(1:2:end,:) = [ u1, u1.*zm - x, 2*u1.*ym, - 2*z - 2*u1.*xm, 2*y, - x - u1.*zm, -2*y, 2*u1.*xm - 2*z, x - u1.*zm, 2*u1.*ym, x + u1.*zm];
N(2:2:end,:) = [ v1, v1.*zm - y, 2*z + 2*v1.*ym, -2*v1.*xm, -2*x, y - v1.*zm, -2*x, 2*v1.*xm, - y - v1.*zm, 2*v1.*ym - 2*z, y + v1.*zm];
MTN = [sum(N(1:2:end,:)); sum(N(2:2:end,:))];

%construct matrix Q: 11*11
Q = N'*N - 1/n*(MTN')*MTN;
const = Q(1,1);
q = Q(1,2:end);
Q = Q(2:end,2:end);

%filter out repetitive solutions
tmp = matrix2quaternion(R);
% xx = tmp(1); yy = tmp(2); zz = tmp(3); tt = tmp(4);

%polish solutions
[xx yy zz tt] = PnP_Polish(Q,q,tmp');

%recover R and t
a = xx; b = yy; c = zz; d = tt; 

lambda1 = 1/(a^2+b^2+c^2+d^2);
if lambda1 > 1e10
    return;
end

vec = [1 a^2 a*b a*c a*d b^2 b*c b*d c^2 c*d d^2];

t0 = 1/n*MTN*vec.';

a = a*sqrt(lambda1); b = b*sqrt(lambda1); c = c*sqrt(lambda1); d = d*sqrt(lambda1);

R0 = [a^2+b^2-c^2-d^2     2*b*c-2*a*d     2*b*d+2*a*c
     2*b*c+2*a*d         a^2-b^2+c^2-d^2 2*c*d-2*a*b
     2*b*d-2*a*c         2*c*d+2*a*b   a^2-b^2-c^2+d^2];
t0 = [lambda1*t0;lambda1-R0(3,:)*Ucent];

end
    
      

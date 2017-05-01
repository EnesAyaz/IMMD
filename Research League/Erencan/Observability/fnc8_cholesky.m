clear all
clc

n = 4;
% Generate a dense n x n symmetric, positive definite matrix

G = rand(n,n); % generate a random n x n matrix

% construct a symmetric matrix using either
G = 0.5*(G+G'); 
G = G*G';
% The first is significantly faster: O(n^2) compared to O(n^3)

% since A(i,j) < 1 by construction and a symmetric diagonally dominant matrix
%   is symmetric positive definite, which can be ensured by adding nI
G = G + n*eye(n);

rank(G)

B = G;

n = length(G);
L = eye(n,n);
L_temp = eye(n,n);
zerovec = zeros(n,1);
zerocounter = 0;

for i = 1:length(G(:,1))-1
   
    
    d = B(i,i);
    
    if (d ==0)   % Then it means there is either rank efficiency or slack bus
        
        zerovec(i,1) = zerocounter;   %Flag the number of dependent rows
        zerocounter=zerocounter+1;    
       
        d = 1;
        
    end
    
     
    a = B(2:(n+1-i),1);
    
    B=B(2:(n+1-i),2:(n+1-i)); %Taking submatrix
    
    B = B-(a*a')./d;       % New submatrix
    

        L_temp(i,i) = sqrt(d);
        L_temp(i+1:n,i) =  a./sqrt(d);
        L = L_temp*L; 
        L_temp = eye(n,n);
    
end
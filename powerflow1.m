%Author:杨家辉
%上传日期：2020.04.30
%快速解耦法计算9节点潮流
%循环变量m\n,p\q,转置变量参数mnmatrix
%输入电网支路参数、节点注入数据(包括节点电压初值)
branchdata=importdata('G:\matlab\powersystem\data\branchdata.txt');
nodedata=importdata('G:\matlab\powersystem\data\nodedata.txt');
%形成节点导纳矩阵ymatrix
ymatrix(1:9,1:9)=0;
for m=1:9
    for n=1:2
       ymatrix(branchdata.data(m,n),branchdata.data(m,n))=ymatrix(branchdata.data(m,n),branchdata.data(m,n))+1/(branchdata.data(m,3)+1i*branchdata.data(m,4))+1i*branchdata.data(m,5); 
    end
    ymatrix(branchdata.data(m,1),branchdata.data(m,2))= -1/(branchdata.data(m,3)+1i*branchdata.data(m,4));
    ymatrix(branchdata.data(m,2),branchdata.data(m,1))=ymatrix(branchdata.data(m,1),branchdata.data(m,2));
end
%将节点重新标号1-9，2-8，3-7，···，8-2，9-1并得到新的节点导纳矩阵
%和支路参数矩阵
ymatrix1(1:9,1:9)=0;
ymatrixexcel=arrayfun(@(x) num2str(x,'%.4f'),ymatrix,'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',ymatrixexcel,2);
for m=1:9
    for n=1:9
        ymatrix1((10-m),(10-n))=ymatrix(m,n);
    end  
end
for m=1:9
    for n=1:2
        branchdata.data(m,n)=10-branchdata.data(m,n);
    end    
end
for m=1:9
    for n=1:1
        nodedata.data(m,n)=10-nodedata.data(m,n);
    end    
end
%求B'(用B1表示)和B"(用B11表示)
%B1采用快速解耦法的改进方法得到
B1(1:8,1:8)=0;
for m=1:8
    for n=1:8
        if m==n
           for p=1:9
                for q=1:2
                    if branchdata.data(p,q)==m
                       B1(m,n)=B1(m,n)-1/branchdata.data(p,4);                               
                    end
                end         
           end
        else
           mnmatrix=[m n];
           mnexc=[n m];
           pqmatrix(1,1:2)=0;
           for p=1:9
               for q=1:2
                   pqmatrix(1,q)=branchdata.data(p,q);    
               end
               if ((pqmatrix(1,1)==mnmatrix(1,1)) && ...
                                           (pqmatrix(1,2)==mnmatrix(1,2)))
                   B1(m,n)=1/branchdata.data(p,4);
               end
               if ((pqmatrix(1,1)==mnexc(1,1)) && ...
                                              (pqmatrix(1,2)==mnexc(1,2)))
                   B1(m,n)=1/branchdata.data(p,4);
               end
           end
        end
    end   
end
%B11由节点导纳矩阵的虚部元素组成
B11(1:6,1:6)=0;
for m=1:6
    for n=1:6
        B11(m,n)=imag(ymatrix1(m,n));   
    end   
end
%设置最大迭代次数为15
kmax=15;
for k=0:14
    %节点电压的矩阵
    Uk(1:8,1:8)=0;
    for m=1:8
        for n=1:8
            if m==n
                for p=1:9
                    if nodedata.data(p,1)== m
                        Uk(m,n)=nodedata.data(p,4);    
                    end    
                end    
            end     
        end  
    end
    %计算deltap和deltaq
    deltap(1:8,1)=0;
    deltaq(1:6,1)=0;
    for m=1:8
        for n=1:9
            if nodedata.data(n,1)== m
               deltap(m,1)=nodedata.data(n,2) -(nodedata.data(n,4))^2*(real(ymatrix1(nodedata.data(n,1),nodedata.data(n,1))));
               if m<7
                  deltaq(m,1)=nodedata.data(n,3)+(nodedata.data(n,4))^2*(imag(ymatrix1(nodedata.data(n,1),nodedata.data(n,1))));
               end
               break;
            end
        end
        for p=1:9
            if (branchdata.data(p,1)==m)
                 for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,2))
                         break;
                     end
                 end
                 deltap(m,1)= deltap(m,1)-nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))+imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5)));
                 if m<7
                    deltaq(m,1)=deltaq(m,1)-nodedata.data(n,4) *nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))); 
                 end
            end
            if(branchdata.data(p,2)==m)
               for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,1))
                         break;
                     end
              end
              deltap(m,1)= deltap(m,1)-nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))+imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5)));
              if m<7
                    deltaq(m,1)=deltaq(m,1)-nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))); 
              end                
            end            
        end  
    end
    %计算判断参数pu和qu
    pu=(Uk(1:8,1:8))\(deltap(1:8,1));
    qu=(Uk(1:6,1:6))\(deltaq(1:6,1));
    pq=[pu;qu];
    if (abs(max(max(pq)))<0.0001) && (k>10)
        break;
    end
    %求deltax
    deltangle=(-B1)\pu;
    deltav=(-B11)\qu;
    %更新PQ节点电压和除平衡节点外的所有电压相角
    for m=1:8
        for n=1:9
            if nodedata.data(n,1)==m
               if m<7
                  nodedata.data(n,4)=nodedata.data(n,4)+deltav(m,1);
               end
                nodedata.data(n,5)=nodedata.data(n,5)+deltangle(m,1);   
            end
        end
    end
end
%判断是否收敛normal
if k==15
    normal=0;
else
    normal=1;  
end
%计算PV节点无功和平衡节点的有功和无功
PVQ(1:2,1)=0;
for m=7:8
    for n=1:9
        if nodedata.data(n,1)==m
            PVQ((m-6),1)=-(nodedata.data(n,4))^2*...
                   (imag(ymatrix1(nodedata.data(n,1),nodedata.data(n,1))));
            break;
        end       
    end
    for p=1:9
            if (branchdata.data(p,1)==m)
                 for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,2))
                         break;
                     end
                 end
                 PVQ((m-6),1)=PVQ((m-6),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))); 
            end
            if (branchdata.data(p,2)==m)
                for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,1))
                         break;
                     end
                end
                PVQ((m-6),1)=PVQ((m-6),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5)));                 
            end            
     end   
end
nodedata.data(3,3)=PVQ(1,1);
nodedata.data(2,3)=PVQ(2,1);
balancePQ(1:2,1)=0;
for m=9:9
        for n=1:9
            if nodedata.data(n,1)== m
               balancePQ((m-8),1)=(nodedata.data(n,4))^2*...
                   (real(ymatrix1(nodedata.data(n,1),nodedata.data(n,1))));
               balancePQ(m-7,1)=-(nodedata.data(n,4))^2*...
                   (imag(ymatrix1(nodedata.data(n,1),nodedata.data(n,1))));   
               break;
            end
        end
        for p=1:9
            if (branchdata.data(p,1)==m)
                 for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,2))
                         break;
                     end
                 end
                 balancePQ((m-8),1)=balancePQ((m-8),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))+imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5)));
                 balancePQ((m-7),1)=balancePQ((m-7),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5)));                 
            end
            if(branchdata.data(p,2)==m)
               for q=1:9
                     if (nodedata.data(q,1)==branchdata.data(p,1))
                         break;
                     end
              end
              balancePQ((m-8),1)= balancePQ((m-8),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5))+imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5)));  
              balancePQ((m-7),1)= balancePQ((m-7),1)+nodedata.data(n,4)*nodedata.data(q,4)*(real(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*sin(nodedata.data(n,5)-nodedata.data(q,5))-imag(ymatrix1(branchdata.data(p,1),branchdata.data(p,2)))*cos(nodedata.data(n,5)-nodedata.data(q,5)));             
            end            
        end  
end
nodedata.data(1,2)=balancePQ(1,1);
nodedata.data(1,3)=balancePQ(2,1);
%%还原节点标号
for m=1:9
    for n=1:2
        branchdata.data(m,n)=10-branchdata.data(m,n);
    end    
end
for m=1:9
    for n=1:1
        nodedata.data(m,n)=10-nodedata.data(m,n);
    end    
end
%变量nodesheet存放潮流计算后的节点数据
nodesheet=nodedata.data;
%输出到excel
nodedataexcel=arrayfun(@(x) num2str(x,'%.4f'),nodesheet,'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',nodedataexcel,3);
%形成包含发电机支路和负荷支路的节点导纳矩阵
ymatrix2=ymatrix;
%矩阵geneload存放发电机节点和负荷节点的序号
geneload=[1 2 3 5 6 8];
for m=1:6
    if m<4
       ymatrix2(geneload(1,m),geneload(1,m)) =ymatrix2(geneload(1,m),geneload(1,m))+1/(1i*nodesheet(geneload(1,m),6));    
    else
       ymatrix2(geneload(1,m),geneload(1,m))=ymatrix2(geneload(1,m),geneload(1,m))+(-nodesheet(geneload(1,m),2)+1i*nodesheet(geneload(1,m),3))/(nodesheet(geneload(1,m),4)^2);     
    end   
end
%输出修正后的发电机节点和负荷节点的自导纳
geneloadmatrix(1:6,1)=0;
for m=1:6
    geneloadmatrix(m,1)=ymatrix2(geneload(1,m),geneload(1,m));
end
%输出到excel
geneloadmatrixexcel=arrayfun(@(x) num2str(x,'%.4f'),geneloadmatrix,'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',geneloadmatrixexcel,4);
%形成节点阻抗矩阵
zmatrix=inv(ymatrix2);
%输出到excel
zfmatrix(1:9,1)=zmatrix(1:9,4);
zfmatrixexcel=arrayfun(@(x) num2str(x,'%.4f'),zfmatrix,'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',zfmatrixexcel,5);
%利用精确算法计算短路电流、各节点电压、电流分布
%短路电流If
If=nodesheet(4,4)*exp(1i*nodesheet(4,5))/zmatrix(4,4);
%模值Ifabs
Ifabs=abs(If);
%相角Ifangle
Ifangle=rad2deg(angle(If));
%短路后各节点电压Uf
Uf(1,1:9)=0;
for m=1:9
    Uf(1,m)=nodesheet(m,4)*exp(1i*nodesheet(m,5))-zmatrix(m,4)*If;  
end
%模值Ufabs
Ufabs=abs(Uf);
%输出到excel
Ufabsexcel=arrayfun(@(x) num2str(x,'%.4f'),(Ufabs.'),'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',Ufabsexcel,6);
%短路后电流分布Idis
Idis(1:9,1:9)=0;
for m=1:9
    for n=1:9       
        for p=1:9
            if (branchdata.data(p,1)==m)&&(branchdata.data(p,2)==n)
                Idis(m,n)=(Uf(1,m)-Uf(1,n))/(branchdata.data(p,3)+1i*branchdata.data(p,4));
            end    
            if (branchdata.data(p,2)==m)&&(branchdata.data(p,1)==n)
                Idis(m,n)=(Uf(1,m)-Uf(1,n))/(branchdata.data(p,3)+1i*branchdata.data(p,4));
            end
        end    
    end   
end
%输出到excel
Idisexcel=arrayfun(@(x) num2str(x,'%.4f'),(Idis),'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',Idisexcel,9);
%利用近似算法计算短路电流、各节点电压、电流分布
%短路电流If1
If1=1/zmatrix(4,4);
%模值If1abs
If1abs=abs(If1);
%相角If1angle
If1angle=rad2deg(angle(If1));
%短路后各节点电压Uf1
Uf1(1,1:9)=0;
for m=1:9
    Uf1(1,m)=1-zmatrix(m,4)*If1;  
end
%模值Uf1abs
Uf1abs=abs(Uf1);
%输出到excel
Uf1absexcel=arrayfun(@(x) num2str(x,'%.4f'),(Uf1abs.'),'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',Uf1absexcel,7);
%比较精确算法和近似算法的电流的幅值误差和相角误差，电压的幅值误差
deltaIabs=(Ifabs-If1abs)/Ifabs;
deltaIangle=(Ifangle-If1angle)/Ifangle;
deltaUabs(1,1:9)=0;
for m=1:9
    deltaUabs(1,m)=(Ufabs(1,m)-Uf1abs(1,m))/Ufabs(1,m);
end
%输出到excel
deltaUabsexcel=arrayfun(@(x) num2str(x,'%.4f'),(deltaUabs.'),'un',0);
xlswrite('G:\matlab\powersystem\homework\data.xlsx',deltaUabsexcel,8);

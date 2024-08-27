clear all
syms theta_rechts theta_links x y l_1 l_2 l_3_rechts l_4 l_3_links
figure;

%Geometrische Parameter in m
l_1 = 0.117;
l_2 = 0.006486;
l_3_rechts = 0.03522;
l_3_links = -l_3_rechts;
l_4 = 0.1;
l_5 = -0.1574;
l_6 = -0.01014;
l_7 = 0.2821;
l_8 = -0.03426;
l_9_rechts = l_3_rechts;
l_9_links = -l_3_rechts;
Armlaenge = 0.2;

%Eingangsparameter
% Gesucht: Thetas, um Gondel in gewünschter Position alpha und beta zu
% bringen
theta_links = -0*pi/180; %Motorwinkel 
theta_rechts = -0*pi/180; %Motorwinkel -1.69 = 0Position
x = 50*pi/180;  %Startwert (20 Grad = 0 Position)
y = 0;
x_links = -50*pi/180;  %Startwert (20 Grad = 0 Position)
y_links = 0;

%Vorgabe
alpha = 4*pi/180; %Gondelwinkel um x
beta = -4*pi/180;  %Gondelwinkel um y

%Vorwärtskinematik Gondel
JointG_r = [
    l_9_rechts*cos(beta) + l_8*sin(beta);   
    cos(alpha)*l_7 + sin(alpha)*sin(beta)*l_9_rechts - sin(alpha)*cos(beta)*l_8 + l_6;
    sin(alpha)*l_7 - cos(alpha)*sin(beta)*l_9_rechts + cos(alpha)*cos(beta)*l_8 + l_5;
    ];

JointG_l = [
    l_9_links*cos(beta) + l_8*sin(beta);
    cos(alpha)*l_7 + sin(alpha)*sin(beta)*l_9_links - sin(alpha)*cos(beta)*l_8 + l_6;
    sin(alpha)*l_7 - cos(alpha)*sin(beta)*l_9_links + cos(alpha)*cos(beta)*l_8 + l_5;
    ];

%Homogene Transformationsmatritzen
P0 = [0;0;0;1];

T5 = sym([          % Unterarm
    1 0 0 0;  
    0 1 0 0;
    0 0 1 -Armlaenge;
    0 0 0 1]);

R5 = sym([          % Kreuzgelenkdrehung um die Y-Achse
    cos(y) 0 sin(y) 0; 
    0 1 0 0;
    -sin(y) 0 cos(y) 0;
    0 0 0 1]);

R5_links = sym([    % Kreuzgelenkdrehung um die Y-Achse
    cos(y_links) 0 sin(y_links) 0;
    0 1 0 0;
    -sin(y_links) 0 cos(y_links) 0;
    0 0 0 1]);
    
R4 = sym([           % Kreuzgelenkdrehung um die X-Achse                  
    1 0 0 0;
    0 cos(x) -sin(x) 0;
    0 sin(x) cos(x) 0;
    0 0 0 1]);
R4_links = sym([     % Kreuzgelenkdrehung um die X-Achse
    1 0 0 0;
    0 cos(x_links) -sin(x_links) 0;
    0 sin(x_links) cos(x_links) 0;
    0 0 0 1]);

T4 = sym([          %Unterarm
    1 0 0 0;  
    0 1 0 l_4;
    0 0 1 0;
    0 0 0 1]);

R3 = sym([          % Motordrehung um die X-Achse 
    1 0 0 0;
    0 cos(theta_rechts) -sin(theta_rechts) 0;
    0 sin(theta_rechts) cos(theta_rechts) 0;
    0 0 0 1]);

R3_links = sym([    % Motordrehung um die X-Achse
    1 0 0 0;
    0 cos(theta_links) -sin(theta_links) 0;
    0 sin(theta_links) cos(theta_links) 0;
    0 0 0 1]);

T3 = sym([          % Transformation Basis zu Motor
    1 0 0 l_3_rechts;  
    0 1 0 l_1;
    0 0 1 l_2;
    0 0 0 1]);

T3_links = sym([    % Transformation Basis zu Motor
    1 0 0 l_3_links;  
    0 1 0 l_1;
    0 0 1 l_2;
    0 0 0 1]);

%Vorwärtskinematik Basis über Ober- und Unterarm zu Gondelangriffspunkt
VK_armR = T3*(R3*(T4*(R4*(R5*(T5*P0)))));
VK_armL = T3_links*(R3_links*(T4*(R4_links*(R5_links*(T5*P0)))));

%1761/50000 - sin(y)/5
%cos(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) + (cos(x)*cos(y)*sin(theta_rechts))/5 + 117/1000
%sin(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) - (cos(theta_rechts)*cos(x)*cos(y))/5 + 7477848878880009/1152921504606846976
%1

VK_start = [ 
            1761/50000 - sin(y)/5;
            cos(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) + (cos(x)*cos(y)*sin(theta_rechts))/5 + 117/1000;
            sin(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) - (cos(theta_rechts)*cos(x)*cos(y))/5 + 7477848878880009/1152921504606846976;
            ];
        
VK_start_links = [ 
            - sin(y)/5 - 1761/50000;
            cos(theta_links)*((cos(y)*sin(x))/5 + 1/10) + (cos(x)*cos(y)*sin(theta_links))/5 + 117/1000;
            sin(theta_links)*((cos(y)*sin(x))/5 + 1/10) - (cos(theta_links)*cos(x)*cos(y))/5 + 7477848878880009/1152921504606846976;
            ];
        
%=====================   |---------------------------------|  ========================================================================
%=====================   | Numerisches Näherungsverfahren  |  ========================================================================
%=====================   |---------------------------------|  ========================================================================
delta = 1;
Schritte = 1;

q = [theta_rechts; x; y];
q_links = [theta_links; x; y];

while max(abs(delta)) >= 0.001


    VK_armR_neu = [
                1761/50000 - sin(q(3))/5;
                cos(q(1))*((cos(q(3))*sin(q(2)))/5 + 1/10) + (cos(q(2))*cos(q(3))*sin(q(1)))/5 + 117/1000;
                sin(q(1))*((cos(q(3))*sin(q(2)))/5 + 1/10) - (cos(q(1))*cos(q(2))*cos(q(3)))/5 + 7477848878880009/1152921504606846976;
                ];
            
    VK_armL_neu = [
                - sin(q_links(3))/5 - 1761/50000;
                cos(q_links(1))*((cos(q_links(3))*sin(q_links(2)))/5 + 1/10) + (cos(q_links(2))*cos(q_links(3))*sin(q_links(1)))/5 + 117/1000;
                sin(q_links(1))*((cos(q_links(3))*sin(q_links(2)))/5 + 1/10) - (cos(q_links(1))*cos(q_links(2))*cos(q_links(3)))/5 + 7477848878880009/1152921504606846976;
                ];
    %     Jmatrix = [
%                jacobian([1761/50000 - sin(y)/5],[theta_rechts,x,y]);
%                jacobian([cos(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) + (cos(x)*cos(y)*sin(theta_rechts))/5 + 117/1000],[theta_rechts,x,y]);
%                jacobian([sin(theta_rechts)*((cos(y)*sin(x))/5 + 1/10) - (cos(theta_rechts)*cos(x)*cos(y))/5 + 7477848878880009/1152921504606846976],[theta_rechts,x,y])
%               ];
    Jmatrix = [
                [0, 0, -cos(q(3))/5];
                [(cos(q(1))*cos(q(2))*cos(q(3)))/5 - sin(q(1))*((cos(q(3))*sin(q(2)))/5 + 1/10), (cos(q(1))*cos(q(2))*cos(q(3)))/5 - (cos(q(3))*sin(q(1))*sin(q(2)))/5, - (cos(q(1))*sin(q(2))*sin(q(3)))/5 - (cos(q(2))*sin(q(1))*sin(q(3)))/5];
                [(cos(q(1))*cos(q(3))*sin(q(2)))/5 + 1/10 + (cos(q(2))*cos(q(3))*sin(q(1)))/5, (cos(q(1))*cos(q(3))*sin(q(2)))/5 + (cos(q(2))*cos(q(3))*sin(q(1)))/5, (cos(q(1))*cos(q(2))*sin(q(3)))/5 - (sin(q(1))*sin(q(2))*sin(q(3)))/5];
               ];
           
    Jmatrix_links = [
                [0, 0, -cos(q_links(3))/5];
                [(cos(q_links(1))*cos(q_links(2))*cos(q_links(3)))/5 - sin(q_links(1))*((cos(q_links(3))*sin(q_links(2)))/5 + 1/10), (cos(q_links(1))*cos(q_links(2))*cos(q_links(3)))/5 - (cos(q_links(3))*sin(q_links(1))*sin(q_links(2)))/5, - (cos(q_links(1))*sin(q_links(2))*sin(q_links(3)))/5 - (cos(q_links(2))*sin(q_links(1))*sin(q_links(3)))/5];
                [(cos(q_links(1))*cos(q_links(3))*sin(q_links(2)))/5 + 1/10 + (cos(q_links(2))*cos(q_links(3))*sin(q_links(1)))/5, (cos(q_links(1))*cos(q_links(3))*sin(q_links(2)))/5 + (cos(q_links(2))*cos(q_links(3))*sin(q_links(1)))/5, (cos(q_links(1))*cos(q_links(2))*sin(q_links(3)))/5 - (sin(q_links(1))*sin(q_links(2))*sin(q_links(3)))/5];
               ];
           
    delta = JointG_r - VK_armR_neu;         %Ziel - aktuelle Position
    delta_links = JointG_l - VK_armL_neu;
    
    Schritte = Schritte+1;
    
    q = q + Jmatrix \ delta;
    q_links = q_links + Jmatrix_links \ delta_links;

    % Plotting the 3D model
    %Vorwärtskinematik des rechten Hebelarm
    x_A_l = l_3_links;
    y_A_l = cos(q_links(1))*l_4 + l_1;
    z_A_l = sin(q_links(1))*l_4 + l_2;
    %Vorwärtskinematik des linken Hebelarm
    x_A_r = l_3_rechts;
    y_A_r = cos(q(1))*l_4 + l_1;
    z_A_r = sin(q(1))*l_4 + l_2;
    
    
    %clf;
    plot3([l_3_rechts x_A_r VK_armR_neu(1)], [l_1 y_A_r VK_armR_neu(2)], [l_2 z_A_r VK_armR_neu(3)], 'r-', 'LineWidth', 2);
    hold on;
    plot3([l_3_links x_A_l VK_armL_neu(1)], [l_1 y_A_l VK_armL_neu(2)], [l_2 z_A_l VK_armL_neu(3)], 'b-', 'LineWidth', 2);
    grid on;
    plot3(JointG_r(1),JointG_r(2),JointG_r(3),'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k')
    plot3(JointG_l(1),JointG_l(2),JointG_l(3),'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    legend('VK\_armR\_neu', 'VK\_armL\_neu', 'JointG\_r', 'JointG\_l');
    title('3D Model');
    drawnow;
    pause(0.5);
    
end

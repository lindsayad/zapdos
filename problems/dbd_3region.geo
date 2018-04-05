//dom0Mult = 1e3;
//dom1Mult = 1e7;
dom0Mult = 1;
dom1Mult = 1;
dom2Mult = 1;

Point(1) = {0, 0, 0, 50e-6 * dom2Mult};
Point(2) = {0.5e-3 * dom2Mult, 0, 0, 50e-6 * dom2Mult};
Point(3) = {1.0e-3 * dom2Mult, 0, 0, 800e-9 * dom0Mult};
Point(4) = {1.0e-3 * dom2Mult + 1.5e-3 * dom0Mult, 0, 0, 50e-6 * dom0Mult};
Point(5) = {1.0e-3 * dom2Mult + 3.0e-3 * dom0Mult, 0, 0, 800e-9 * dom0Mult};
Point(6) = {1.0e-3 * dom2Mult + 3.0e-3 * dom0Mult + 0.5e-3 * dom1Mult, 0, 0, 50e-6 * dom1Mult};
Point(7) = {1.0e-3 * dom2Mult + 3.0e-3 * dom0Mult + 1.0e-3 * dom1Mult, 0, 0, 50e-6 * dom1Mult};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,5};
Line(5) = {5,6};
Line(6) = {6,7};

Physical Line(2) = {1,2};
Physical Line(0) = {3,4};
Physical Line(1) = {5,6};

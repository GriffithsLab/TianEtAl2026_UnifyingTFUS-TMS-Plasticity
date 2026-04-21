function y_next = rk4_step(rhs, y, h)
    k1 = rhs(y);
    k2 = rhs(y + 0.5*h*k1);
    k3 = rhs(y + 0.5*h*k2);
    k4 = rhs(y + h*k3);
    y_next = y + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
end

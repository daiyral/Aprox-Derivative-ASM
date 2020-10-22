// multi_approx.c
#include <stdio.h>
#include <math.h>
extern double single_partial_derivative(double (*obj_f)(double x[]),
     int i, double x[], double h);
extern double approx_partial_derivative(double (*obj_f)(double x[]),
     int i, double x[]);
double f(double x[])
{
  return (-sin(x[0]+2*x[1]) - cos(3*x[0]+4*x[1])); 

} // f
void compute_exact_g(double grad[], double x[], int n)
{
  if(n<2) return;
  grad[0] = -cos(x[0]+2*x[1])+ 3*sin(3*x[0]+4*x[1]) ; 
  grad[1] = -2*cos(x[0]+2*x[1])+ 4*sin(3*x[0]+4*x[1]); 

} // exact_g
void compute_approx_g(double (*f)(double[]), double grad[], double x[], int n)
{
  int i;
  for(i=0; i < n; i++)
     grad[i] = approx_partial_derivative(f,i, x); 

} // compute_approx_g
int main()
{
  double exact_g[2], approx_g[2], x[2], value;
  x[0] = -3.0;
  x[1] = 2.0;
  compute_exact_g(exact_g, x, 2);
  compute_approx_g(f, approx_g, x, 2);
  printf("exact_g[0] = %lf,  exact_g[1] = %lf\n",  
      exact_g[0],  exact_g[1]);
  printf("approx_g[0] = %lf,  approx_g[1] = %lf\n",  
      approx_g[0],  approx_g[1]);
  return 0;
} // main

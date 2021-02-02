#Arithmetic Operations

#Using Defined Variables

A=20
B=10
echo "Sum is $(( A + B))"
echo "Difference is $(( A - B))"
echo "Product is $(( A * B))"
echo "Quotient is $(( A / B))"

#Using Command-Line Arguements

A=$1
B=$2
echo "Sum is $(( A + B))"
echo "Difference is $(( A - B))"
echo "Product is $(( A * B))"
echo "Quotient is $(( A / B))"


#Not rounding off the value
num1=$1
num2=$2
num3=$3
sum=$(( num1 + num2 + num3 ))
average=$(echo "$sum / 3" | bc -l)
echo "$average"
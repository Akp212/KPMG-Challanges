function abc()
{
echo "enater object:"
read object
echo "enter key:"
read key
object="$(echo $object | sed 's/://g')"
object="$(echo $object | sed 's/{//g')"
object="$(echo $object | sed 's/"//g')"
object="$(echo $object | sed 's/}//g')"
key="$(echo $key | sed 's\/\\g')"
value=$(echo $object | tr -d $key)
echo "value is: $value"
}
abc

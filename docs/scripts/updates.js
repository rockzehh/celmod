var rows = document.getElementsByTagName('tr');
for(var i = 0; i < rows.length; i++)
{
	if(i % 2 != 0)
		rows[i].style.backgroundColor = "#333333";
	else
		rows[i].style.backgroundColor = "#444444";
}
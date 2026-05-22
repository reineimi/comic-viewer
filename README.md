# comics-index
> A Lua script that generates JSON tables of comic volumes & chapters, and then parses them into an HTML file written in [Va2](https://github.com/reineimi/va2) frontend library.

> [!TIP]
> Guide on how to run Lua files on Windows <a href='https://github.com/reineimi/lua-on-windows' target='_blank'>can be viewed here</a>.

## Usage
```
1.	Put this script in the directory of the
	downloaded comics you want to view.

2.	Rename the directories following the rules below:

	Directory tree before changes:
		> My Comic Book
			> Volume 1 - The Beginning
			> Volume 2 - The Progress
			> Chapter 12
			> Chapter 13

	After changes:
		> My_Comic_Book
			> v01
			> v02
			> 012
			> 013
			cover.jpg

3.	Only after that, run the script, and then open
	the generated index.html file in your browser.
```

> [!NOTE]
> Be wary of the fact that the opened HTML documents may require one or several gigabytes of RAM.

> [!TIP]
> You can change the colors in the **Settings** menu, which is accessible in the **context menu** that appears on **right click/long tap**.

## Example structure (Windows)
<img width="543" height="341" alt="image" src="https://github.com/user-attachments/assets/4d718f30-e0eb-49e1-8813-d2e7446ddfec" />

## Preview (Desktop)
*Volumes*
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/d553f9f8-fb42-4812-9951-f5633869fc01" />

*Gallery*
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/033716f4-2a30-41c0-999e-7d6aec84ba9d" />

*Pages*
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/91a446da-bec3-495a-95c1-21d934ffdfc3" />

## Preview (Mobile)
<img width="412" height="915" alt="image" src="https://github.com/user-attachments/assets/951bbfee-1929-40ae-97b5-d18465929b6c" />
<img width="412" height="915" alt="image" src="https://github.com/user-attachments/assets/0b4f2009-63f4-4130-b9f3-0acb63205d46" />
<img width="412" height="915" alt="image" src="https://github.com/user-attachments/assets/2fb3b2ae-dbba-4cb5-9132-2c5ddee2fd3b" />

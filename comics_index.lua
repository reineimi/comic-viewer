print([[How to use:
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

(Note: volumes under 10 must include a 0 at the start,
same goes for chapters under 100, e.g: v09, 009, 099)
]])

-- Get book titles
local entries = {}
local p = io.popen('dir /ad /b')
for dir in p:lines() do
	local entry = {
		alias = dir,
		title = dir:gsub('_', ' '),
		vol = {},
		ch = {}
	}
	-- Get volumes and chapters
	local p2 = io.popen('cd '..dir..' && dir /ad /b')
	for ind in p2:lines() do
		if ind:match('^v[%d]+') then
			table.insert(entry.vol, ind)
		else
			table.insert(entry.ch, ind)
		end
	end
	p2:close()
	entry.vol_total = #entry.vol
	entry.ch_total = #entry.ch
	if entry.ch[1] then
		entry.ch_start = tonumber(entry.ch[1])
		entry.ch_end = entry.ch_start + (entry.ch_total-1)
	end

	print '\n-- Entry found --'
	print('Title:', entry.title)
	print('Volumes total:', entry.vol_total)
	print('Chapters total:', entry.ch_total)
	print('First chapter:', entry.ch_start)
	print('Last chapter:', entry.ch_end)
	table.insert(entries, entry)
end
p:close()

-- Content generation logic
local function run(entry)
	local alias = entry.alias
	local title = entry.title
	local vol = {}
	local chap = {}
	local vol_total = entry.vol_total
	local ch_start = entry.ch_start
	local ch_end = entry.ch_end
	local ch_total = entry.ch_total

	-- Create volume list
	local vol = {}
	for i,V in ipairs(entry.vol) do
		local p = io.popen('cd '..alias..' && dir /b '..V)
		vol[i] = {}
		for ln in p:lines() do
			table.insert(vol[i], '"'..ln..'"')
		end
		p:close()
	end

	-- Create chapters list
	if ch_start then
		for i,ch in ipairs(entry.ch) do
			local p = io.popen('cd '..alias..' && dir /b '..ch)
			chap[i+1] = {}
			for ln in p:lines() do
				table.insert(chap[i+1], '"'..ln..'"')
			end
			p:close()
		end
	end

	-- Generate JSON file contents
	local json = {
	[[{
		"title": "]]..title..[[",
		"volumes": []]
	}

	---- Volumes
	for i,v in ipairs(vol) do
		local comma = ''
		if i < #vol then
			comma = ','
		end
		table.insert(json, string.format(
			'		[\n			%s\n		]%s',
			table.concat(v, ',\n			'),
			comma
		))
	end
	table.insert(json, [[	],
		"chapters": []])

	---- Chapters
	for i,v in pairs(chap) do
		local comma = ''
		if i < #chap then
			comma = ','
		end
		table.insert(json, string.format(
			'		[\n			%s\n		]%s',
			table.concat(v, ',\n			'),
			comma
		))
	end
	table.insert(json, '	]\n}')

	-- Write JSON and JS files
	local f = io.open(alias..'/volumes.json', 'w')
	f:write(table.concat(json, '\n'))
	f:close()

	local f = io.open(alias..'/volumes.js', 'w')
	f:write('const volumes = '..table.concat(json, '\n')..';')
	f:close()

	-- Write HTML file
	local f = io.open(alias..'/'..alias:lower()..'.html', 'w')
	f:write([[
<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'>
	<meta name='viewport' content='width=device-width, height=device-height, initial-scale=1.0, viewport-fit=cover'>
	<title>]]..title..[[</title>
	<link rel='stylesheet' href='https://reineimi.github.io/va2/lib/va2.css'>
	<script src='https://reineimi.github.io/va2/lib/va2.js' async></script>
	<script src='volumes.js'></script>
	<script>
	const sel = {};
	let vol_now = 0;
	let page_now = 0;
	let pages_total = 0;
	let vol_ch = 'Volume';
	const alias = "]]..alias..[[";
	const ch_start = ]]..(ch_start or 0)..[[;

	sel.vol = function(number) {
		vol_ch = 'Volume ';
		loop(volumes.volumes.length, (n)=>{
			hide('vol'+(n+1));
		});
		loop(volumes.chapters.length, (n)=>{
			hide('vol'+(ch_start+n));
		});
		hide('Volumes', 'Viewer');
		show('Gallery', 'vol'+number);
		emi('title_nav').innerHTML = vol_ch+number;
		pages_total = volumes.volumes[number-1].length;
		va2.data[alias].pagesTotal = pages_total;
		emi('Main').scrollTo({top:0,behaviour:'smooth'});
	}

	sel.ch = function(number) {
		vol_ch = 'Chapter ';
		loop(volumes.volumes.length, (n)=>{
			hide('vol'+(n+1));
		});
		loop(volumes.chapters.length, (n)=>{
			hide('vol'+(ch_start+n));
		});
		hide('Volumes', 'Viewer');
		show('Gallery', 'vol'+number);
		emi('title_nav').innerHTML = vol_ch+number;
		pages_total = volumes.chapters[number-ch_start].length;
		va2.data[alias].pagesTotal = pages_total;
		emi('Main').scrollTo({top:0,behaviour:'smooth'});
	}

	sel.page = function(n_vol, n_page) {
		let src = emi('vol'+n_vol+'_page'+n_page).src;
		emi('viewer_img').src = src;
		if (emi('vol'+n_vol+'_page'+(n_page+1))) {
			let src2 = emi('vol'+n_vol+'_page'+(n_page+1)).src;
			emi('viewer_img2').src = src2;
		} else {
			emi('viewer_img2').src = '';
		}
		show('Viewer', 'vol'+n_vol);
		hide('Volumes', 'Gallery');
		emi('title_nav').innerHTML = vol_ch+n_vol+', Page '+n_page;
		vol_now = n_vol;
		page_now = n_page;
		va2.data[alias].vol = n_vol;
		va2.data[alias].page = n_page;
		emi('Main').scrollTo({top:0,behaviour:'smooth'});
	}

	window.addEventListener('load', ()=>{
		va2.data.accentColor = 'crimson'; init();
		va2.data[alias] = {};
		mk('va2ctxtItems',
			"<a href='../index.html'>Back to Library</a>",
			"<p class='cred' onclick='storage.wipe()'>Clear data</p>")

		// Viewer scroll logic
		emi('p_prev').onclick = ()=>{
			if (page_now > 1) {
				page_now -= 2;
			}
			if (emi('vol'+vol_now+'_page'+(page_now))) {
				let src = emi('vol'+vol_now+'_page'+page_now).src;
				emi('viewer_img').src = src;
				let src2 = emi('vol'+vol_now+'_page'+(page_now+1)).src;
				emi('viewer_img2').src = src2;
			} else {
				emi('viewer_img').src = emi('vol'+vol_now+'_page1').src;
				emi('viewer_img2').src = emi('vol'+vol_now+'_page2').src;
				page_now = 1;
			}
			emi('title_nav').innerHTML = vol_ch+vol_now+', Page '+page_now;
			va2.data[alias].vol = vol_now;
			va2.data[alias].page = page_now;
			emi('Main').scrollTo({top:0,behaviour:'smooth'});
		}
		emi('p_next').onclick = ()=>{
			if (page_now < (pages_total-1)) {
				page_now += 2;
			}
			let src = emi('vol'+vol_now+'_page'+page_now).src;
			emi('viewer_img').src = src;
			if (emi('vol'+vol_now+'_page'+(page_now+1))) {
				let src2 = emi('vol'+vol_now+'_page'+(page_now+1)).src;
				emi('viewer_img2').src = src2;
			} else {
				emi('viewer_img2').src = '';
			}
			emi('title_nav').innerHTML = vol_ch+vol_now+', Page '+page_now;
			va2.data[alias].vol = vol_now;
			va2.data[alias].page = page_now;
			emi('Main').scrollTo({top:0,behaviour:'smooth'});
		}

		// Generate volumes
		loop(volumes.volumes, (vol,files)=>{
			const vol_body = create(0, {
				className: 'w f hide',
			}, 'Gallery');
			vol_body.dataset.uid = 'vol'+(vol+1);
			loop(files, (i,v)=>{
				let num = vol+1;
				if (num < 10) { num = '0'+num; }
				const path = 'v'+num+'/'+v;
				// Volume cover
				if (i === 0) {
					mk('Volumes', `<div class='w1-4 p1' onclick="sel.vol(${vol+1})"><img src="${path}" class='w imfit br'><p class='tc fs1-1 fw7'>Volume ${vol+1}</p></div>`);
				}
				mk(vol_body, `<div class='w1-4 p05 pb0' onclick="sel.page(${vol+1},${i+1})"><img data-uid='vol${vol+1}_page${i+1}' src="${path}" class='w imfit'></div>`);
			});
		});

		// Generate chapters
		loop(volumes.chapters, (ch,files)=>{
			const ch_body = create(0, {
				className: 'w f hide',
			}, 'Gallery');
			ch_body.dataset.uid = 'vol'+(ch_start+ch);
			loop(files, (i,v)=>{
				let num = ch_start+ch;
				if (num < 100) { num = '0'+num; }
				const path = num+'/'+v;
				// Chapter cover
				if (i === 0) {
					mk('Volumes', `<div class='w1-4 p1' onclick="sel.ch(${ch_start+ch})"><img src="${path}" class='w imfit br'><p class='tc fs1-1 fw7'>Chapter ${ch_start+ch}</p></div>`);
				}
				mk(ch_body, `<div class='w1-4 p05 pb0' onclick="sel.page(${ch_start+ch},${i+1})"><img data-uid='vol${ch_start+ch}_page${i+1}' src="${path}" class='w imfit'></div>`);
			});
		});

		// Load progress
		va2.f.loadData();
		if (va2.data[alias].page) {
			vol_now = va2.data[alias].vol || 0;
			page_now = va2.data[alias].page || 0;
			pages_total = va2.data[alias].pagesTotal || 0;
			sel.page(vol_now, page_now);
		}
	});
	</script>
</head>
<body class='ts-all fh scroll'>
	<div id='Header' class='w px1 pt1'>
		<div class='w th_windowFg shadowS b2px bbgi br px1 f'>
			<h1 class='w1-6-3 py1 pl1 m h2 fw9 ls1 lh1 c'>]]..title..[[ <x data-uid='title_nav' class='fc fs1'></x></h1>
			<div class='w1-6-3 py1 f tc fs1-4 lh08 nosel'>
				<div class='m mr0 f g1 px05-g py1-g end c br1-g b2px-g pt-g'>
					<div class='wr5 bbgi bgic-hov' onclick='fullscreen()'><p class='gicon'>fit_screen</p><br><x class='fs07'>Fullscreen</x></div>
					<div class='wr5 bbgi bgic-hov' onclick="va2.f.saveData(); notify('Progress saved!', 'green cwhite', {silent:1})"><p class='gicon'>beenhere</p><br><x class='fs07'>Bookmark</x></div>
					<div class='wr5 bbgi bgic-hov' onclick="show('Volumes'); hide('Viewer','Gallery'); wipe('title_nav')"><p class='gicon'>book_2</p><br><x class='fs07'>Volumes</x></div>
					<div class='wr5 bbgi bgic-hov' onclick="hide('Volumes','Viewer'); show('Gallery')"><p class='gicon'>photo_library</p><br><x class='fs07'>Gallery</x></div>
				</div>
			</div>
		</div>
	</div>
	<main id='Main' class='w f1 scroll p1 f nosel'>
		<div id='Volumes' class='w f start'></div>
		<div id='Viewer' class='m f hide'>
			<img data-uid='viewer_img' class='m h-m w-m imfit'>
			<img data-uid='viewer_img2' class='m h-m w-m imfit'>
			<div data-uid='p_prev' class='abs topL h w1-2 z1'></div>
			<div data-uid='p_next' class='abs topR h w1-2 z1'></div>
		</div>
		<div id='Gallery' class='p1 mb1-g hide'></div>
	</main>
</body>
</html>
]])
	f:close()
end

print '\nGenerating content...'
local html_entries = {}
for _,e in ipairs(entries) do
	run(e)
	table.insert(html_entries, string.format([[
		<div class='w1-4 p05 tc'>
			<div class='p1 bgic br b1px bfgi bgc-hov bc-hov fw5'>
				<a href='%s/%s.html' class='fill z2 pt'></a>
				<img src='%s/cover.jpg' class='w brS' alt='cover' />
				<p class='fs1-3 fw8 c'>%s</p>
				<p>Volumes: %s</p>
				<p>Chapters: %s</p>
			</div>
		</div>]],
		e.alias, e.alias:lower(), e.alias, e.title, e.vol_total, e.ch_total
	))
end

-- Entry index
local f = io.open('index.html', 'w')
f:write([[
<!DOCTYPE html><html lang='en'><head><meta charset='utf-8'>
	<meta name='viewport' content='width=device-width, height=device-height, initial-scale=1.0, viewport-fit=cover'>
	<title>Comics library</title>
	<link rel='stylesheet' href='https://reineimi.github.io/va2/lib/va2.css'>
	<script src='https://reineimi.github.io/va2/lib/va2.js' async></script>
	<script>
	window.addEventListener('load', ()=>{
		va2.data.accentColor = 'crimson'; init();
	});
	</script>
</head>
<body class='ts-all f p1 pt0 bgc'>
	<header class='f m px3 bgn bn' style='width:unset'>
		<h1 class='m w tc fs1-6 fw8 fontCode py2 px3 fgc br'><c>Library entries</c> (]]..#html_entries..[[)</h1>
	</header>
	<main id='Main' class='m center mx0-g scroll br fgc p05 b1px bbgi'>
]]..table.concat(html_entries, '\n')..'\n'..[[
	</main>
</body>
</html>
]])
f:close()

print 'Done. Press Enter to close.'; io.read()

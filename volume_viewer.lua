-- Get initial info
io.write 'Comic/book title: '
local title = io.read()
io.write 'Volumes total: '
local vol_total = io.read()

-- Create volume list
local vol = {}
for i = 1, tonumber(vol_total) do
	local V = 'v0'..i
	local p = io.popen('dir /b '..V)
	vol[i] = {}
	for ln in p:lines() do
		table.insert(vol[i], '"'..ln..'"')
	end
	p:close()
end

-- Generate JSON file contents
local json = {
[[{
	"title": "]]..title..[[",
	"volumes": []]
}
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
table.insert(json, [[	]
}]])

-- Write JSON and JS files
local f = io.open('volumes.json', 'w')
f:write(table.concat(json, '\n'))
f:close()

local f = io.open('volumes.js', 'w')
f:write('const volumes = '..table.concat(json, '\n')..';')
f:close()

-- Write HTML file
local f = io.open(title:lower():gsub(' ', '_')..'.html', 'w')
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

	sel.vol = function(number) {
		loop(volumes.volumes.length, (n)=>{
			hide('vol'+n);
		});
		hide('Volumes', 'Viewer');
		show('Gallery', 'vol'+number);
		emi('title_nav').innerHTML = 'Volume '+number;
		pages_total = volumes.volumes[number-1].length;
		va2.data.pagesTotal = pages_total;
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
		emi('title_nav').innerHTML = 'Volume '+n_vol+', Page '+n_page;
		vol_now = n_vol;
		page_now = n_page;
		va2.data.vol = n_vol;
		va2.data.page = n_page;
	}

	window.addEventListener('load', ()=>{
		va2.data.accentColor = 'crimson';
		init({proto:1});

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
			emi('title_nav').innerHTML = 'Volume '+vol_now+', Page '+page_now;
			va2.data.vol = vol_now;
			va2.data.page = page_now;
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
			emi('title_nav').innerHTML = 'Volume '+vol_now+', Page '+page_now;
			va2.data.vol = vol_now;
			va2.data.page = page_now;
		}

		// Generate content
		loop(volumes.volumes, (vol,files)=>{
			const vol_body = create(0, {
				className: 'w f hide',
			}, 'Gallery');
			vol_body.dataset.uid = 'vol'+(vol+1);
			loop(files, (i,v)=>{
				const path = 'v0'+(vol+1)+'/'+v;
				// Volume cover
				if (i === 0) {
					mk('Volumes', `<div class='w1-4 p1' onclick="sel.vol(${vol+1})"><img src='${path}' class='w imfit br'><p class='tc fs1-1 fw7'>Volume ${vol+1}</p></div>`);
				}
				mk(vol_body, `<div class='w1-4 p05 pb0' onclick="sel.page(${vol+1},${i+1})"><img data-uid='vol${vol+1}_page${i+1}' src='${path}' class='w imfit'></div>`);
			});
		});

		// Load progress
		va2.f.loadData();
		if (va2.data.page) {
			vol_now = va2.data.vol || 0;
			page_now = va2.data.page || 0;
			pages_total = va2.data.pagesTotal || 0;
			sel.page(vol_now, page_now);
		}
	});
	</script>
</head>
<body class='ts-all fh scroll'>
	<div id='Header' class='w px1 pt1'>
		<div class='w th_windowFg shadowS b2px bbgi br py1 px2 f'>
			<h1 class='w1-6-3 py1 m h2 fw9 ls1 c'>]]..title..[[ <x data-uid='title_nav' class='fc fs1'></x></h1>
			<div class='w1-6-3 py1 f tc fs1-4 lh1 nosel'>
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

print 'Done. Press Enter to close.'; io.read()

'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "afafa57f088414a6b5a846ce32e22515",
"index.html": "f8fdd577074d65365d8a938af2e6e7b0",
"/": "f8fdd577074d65365d8a938af2e6e7b0",
"main.dart.js": "2921bfc270f685eddea3402381eee857",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "cc8040f4e6a2e1d01146f573748f2e2b",
"assets/AssetManifest.json": "6ddfcd552015e515c55c5ffc99bcf0a0",
"assets/NOTICES": "84bce54ed1477a5b09e8fdb1230c042f",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/shaders/ink_sparkle.frag": "20887133e2f8a3d704f0140d68776904",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/assets/dummy/post9.jpg": "e365b07bb7c3e4b6545ea568122f011d",
"assets/assets/dummy/post8.jpg": "0bac190a4906256e2c8a5c62518c42cb",
"assets/assets/dummy/post10.jpg": "3c019b94bff1380ed8c17cb331590853",
"assets/assets/dummy/post5.jpg": "cb355c1fbfebacf76e8e52cfc35e87cb",
"assets/assets/dummy/post4.jpg": "1db26b28123cc2c09f72b2bfb4b80e73",
"assets/assets/dummy/post6.jpg": "a8bc212541257b3f4439ac34f313d705",
"assets/assets/dummy/post7.jpg": "4f2001ec4abdd405224a4b8d07bb3d53",
"assets/assets/dummy/post3.jpg": "4d532cd210ba319340a5ceab4d17657d",
"assets/assets/dummy/post2.jpg": "2b87c7c6f6f6d87cfeffe3a3c0813d98",
"assets/assets/dummy/post1.jpg": "2c9ed9714e6195ecea5553f45b26a540",
"assets/assets/nft/cow.svg": "8a632225f985fa00f50330836fa193bf",
"assets/assets/nft/kraken.svg": "9eed34001133283409fb7d6acabc215c",
"assets/assets/nft/seahorse.svg": "5a4b778124158b451d94515b813debda",
"assets/assets/nft/fish.svg": "ffcb6ad892a718fa44e68634585b2ea3",
"assets/assets/nft/pig.svg": "c371eecb5d770e3e3e59f464d1936aa6",
"assets/assets/nft/wolf.svg": "93414f8028063ebe1b8bb051e8ec9a82",
"assets/assets/logo/instagram_logo_with_name.png": "e7958030051fefba61c859f95ff99e44",
"assets/assets/icon/grid.svg": "bf67a4fd5ef3e3141786ed9a335fb1e8",
"assets/assets/icon/search.svg": "b1a9b14caab92fe128e7df6a7c01a487",
"assets/assets/icon/logout.svg": "8b6d2ee662e8eef55543cbda099e5a4b",
"assets/assets/icon/settings2.svg": "b73fb8da52a844e3d3734878fc8f2d73",
"assets/assets/icon/igtv.svg": "159322693db97038804d7b8ec04e933e",
"assets/assets/icon/direct_message.svg": "07f999d7d8a3dcf8a70b54dc3a482d77",
"assets/assets/icon/statistic.svg": "8497cf6327f9c38a24dcbd3766890af7",
"assets/assets/icon/notification_bell.svg": "e5f2f71afa6a5fafb31a0d7537d9cdba",
"canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

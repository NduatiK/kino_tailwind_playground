export function init(ctx, payload) {
  ctx.importCSS('main.css');
  ctx.root.innerHTML = `
      <div class="wrapper">
        <div class="button-header">
          <button data-width="375px" class="size-btn text-sm">
            xs
          </button>
          <button data-width="640px" class="size-btn text-sm">
            sm
          </button>
          <button data-width="768px" class="size-btn text-sm">
            md
          </button>
          <button data-width="100%" class="size-btn active">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25" />
            </svg>
          </button>
        </div>
        <div id="iframe-container">
          <iframe id="iframe" loading="eager" width="100%" height="100%"></iframe>
        </div>
      </div>
    `;
  ctx.importJS('./tailwind.js').then(() => {
    let iframe = ctx.root.querySelector('#iframe');
    let buttons = document.querySelectorAll('.size-btn');

    iframe.srcdoc = `
          <head>
            <script src='./tailwind.js'></script>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body id="body">
          </body>
        `;
    buttons.forEach((btn) => {
      if (payload.default_width) {
        iframe.style.maxWidth = payload.default_width;
        if (btn.dataset.width === payload.default_width) {
          buttons.forEach((btn) => {
            btn.classList.remove('active');
          });
          btn.classList.add('active');
        }
      }

      btn.addEventListener('click', (e) => {
        iframe.style.maxWidth = e.target.dataset.width;
        buttons.forEach((btn) => {
          btn.classList.remove('active');
        });
        e.target.classList.add('active');
        ctx.pushEvent('resized', {
          width: iframe.style.maxWidth
        });
      });
    });

    let iframeContainer = ctx.root.querySelector('#iframe-container');

    if (payload.default_height) {
      iframeContainer.style.height = payload.default_height;
    }

    ctx.handleEvent('display-html', ({ html }) => {
      try {
        let body = iframe.contentWindow.document.querySelector('#body');
        body.innerHTML = html;
      } catch {
        setTimeout(() => {
          let body = iframe.contentWindow.document.querySelector('#body');
          body.innerHTML = html;
        }, 1000);
      }
    });

    ctx.handleSync(() => {
      // Synchronously invokes change listeners
      document.activeElement &&
        document.activeElement.dispatchEvent(new Event('change'));

      iframe.contentWindow.addEventListener('resize', () => {
        ctx.pushEvent('resized', {
          height: iframeContainer.style.height
        });
      });

      ctx.pushEvent('initial-render', {});
    });
  });
  // });
}

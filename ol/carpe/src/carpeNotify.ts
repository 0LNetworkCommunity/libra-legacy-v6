
import UIkit from 'uikit';


export function success(s: string) {
  UIkit.notification({
    message: `<span uk-icon=\'icon: check\'></span> ${s}`,
    pos: 'bottom-center',
    status: 'success',
    timeout: 3000
  });
}


export function error(s: string) {
  UIkit.notification({
    message: `<span uk-icon=\'icon: warning\'></span> ${s}`,
    pos: 'bottom-center',
    status: 'error',
    timeout: 3000
  });
}
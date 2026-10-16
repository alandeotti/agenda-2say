// Check do responsável, dos links (plataforma + validação) e da data do e-mail. Rodar: node _check.mjs
import fs from 'fs'; import vm from 'vm'; import assert from 'assert';
const html = fs.readFileSync('index.html', 'utf8');
const js = html.split('<script>').pop().split('</script>')[0];
new vm.Script(js); // sintaxe da página inteira
const pega = n => js.match(new RegExp('function ' + n + '\\([\\s\\S]*?\\n}'))[0];
const ctx = {sessao:{email:'Renata@x.com'}, membrosMarca:[{email:'eduardodeotti3@gmail.com', nome:'Alan'}],
  esc: s => String(s==null?'':s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]))};
vm.createContext(ctx); vm.runInContext(pega('nomeResp') + pega('opcoesResp'), ctx);
assert.equal(ctx.nomeResp('Alan'), 'Alan');                       // card antigo
assert.equal(ctx.nomeResp('EDUARDODEOTTI3@gmail.com'), 'Alan');   // e-mail -> nome curto
assert.equal(ctx.nomeResp('fulano@y.com'), 'fulano');             // fora da lista
const op = ctx.opcoesResp('Alan');
assert.match(op, /value="Alan" selected>Alan \(antigo\)/);        // antigo continua selecionado
assert.match(op, /value="renata@x.com"/);                         // eu entro mesmo fora da lista
assert.match(ctx.opcoesResp('eduardodeotti3@gmail.com'), /value="eduardodeotti3@gmail.com" selected>Alan</);
assert.doesNotMatch(ctx.opcoesResp(''), /selected/);              // card novo: nada escolhido

const lk = {URL}; vm.createContext(lk);
vm.runInContext(pega('linkOk') + pega('dominio') + pega('plataforma') + pega('ytId'), lk);
assert.equal(lk.linkOk('javascript:alert(1)'), '');               // só http(s)
assert.equal(lk.linkOk('data:text/html,oi'), '');
assert.equal(lk.linkOk('nem é link'), '');
assert.equal(lk.linkOk(' https://x.com/a '), 'https://x.com/a');
assert.equal(lk.plataforma('https://www.instagram.com/reel/abc/'), 'Reels');
assert.equal(lk.plataforma('https://youtu.be/dQw4w9WgXcQ'), 'YouTube');
assert.equal(lk.plataforma('https://vm.tiktok.com/xyz'), 'TikTok');
assert.equal(lk.plataforma('https://youtube.com.golpe.io/v'), 'Link');    // domínio parecido não engana
assert.equal(lk.plataforma('https://notyoutube.com/v'), 'Link');
assert.equal(lk.ytId('https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=3'), 'dQw4w9WgXcQ');
assert.equal(lk.ytId('https://youtube.com/shorts/dQw4w9WgXcQ'), 'dQw4w9WgXcQ');
assert.equal(lk.ytId('https://youtu.be/"><img'), '');

// a edge function não está no repo: só confere quando existir
if(fs.existsSync('supabase/functions/avisa-email/index.ts')){
const ts = fs.readFileSync('supabase/functions/avisa-email/index.ts', 'utf8');
const quando = new Function(ts.match(/const DIAS = [^\n]*\n/)[0] + ts.match(/const DIAS_LONGO = [^\n]*\n/)[0] +
  'return ' + ts.match(/function quando[\s\S]*?\n}/)[0].replace(/: string/g, ''))();
assert.equal(quando('2026-W42', 'sex'), 'sexta, 16/10');
assert.equal(quando('2026-W01', 'seg'), 'segunda, 29/12');        // semana ISO que começa no ano anterior
assert.equal(quando('lixo', 'qua'), 'quarta');
}
console.log('ok');

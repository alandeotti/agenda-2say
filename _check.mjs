// Check da lógica do responsável e da data do e-mail. Rodar: node _check.mjs
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

const ts = fs.readFileSync('supabase/functions/avisa-email/index.ts', 'utf8');
const quando = new Function(ts.match(/const DIAS = [^\n]*\n/)[0] + ts.match(/const DIAS_LONGO = [^\n]*\n/)[0] +
  'return ' + ts.match(/function quando[\s\S]*?\n}/)[0].replace(/: string/g, ''))();
assert.equal(quando('2026-W42', 'sex'), 'sexta, 16/10');
assert.equal(quando('2026-W01', 'seg'), 'segunda, 29/12');        // semana ISO que começa no ano anterior
assert.equal(quando('lixo', 'qua'), 'quarta');
console.log('ok');

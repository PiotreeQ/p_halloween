const rankingWrapper = $('.ranking-wrapper');
const rankingPlayers = $('.ranking-players');

const LoadLeaderboard = ((data) => {
    rankingPlayers.empty();
    let inLeaderboard = false;
    const stats = data.stats;
    for (let i in data.leaderboard) {
        let player = data.leaderboard[i];
        let thisPlayer = false;
        if (stats.identifier && stats.identifier == player.identifier) {
            inLeaderboard = true;
            thisPlayer = true;
        }
        rankingPlayers.append(`
            <div class="ranking-player ${thisPlayer ? 'you' : ''}">
                <div class="ranking-avatar">
                    <img class="avatar" src="${player.avatar}" alt="">
                    <div class="ranking-pos"><b>${parseInt(i) + 1}</b></div>
                </div>
                <div class="player-info">
                    <span>${thisPlayer ? 'Your stats' : 'Player'}</span>
                    <span>${player.name}</span>
                </div>
                <div class="player-points">
                    <div class="points-box"><img src="img/pumpkin.png" alt=""></div>
                    <span>${player.pumpkins}</span>
                </div>
            </div>`);
    }

    if (!inLeaderboard) {
        rankingPlayers.append(`
            <div class="ranking-player you">
                <div class="ranking-avatar">
                    <img class="avatar" src="${stats.avatar}" alt="">
                    <div class="ranking-pos"><b>${stats.id}</b></div>
                </div>
                <div class="player-info">
                    <span>Your stats</span>
                    <span>${stats.name}</span>
                </div>
                <div class="player-points">
                    <div class="points-box"><img src="img/pumpkin.png" alt=""></div>
                    <span>${stats.pumpkins}</span>
                </div>
            </div>`)
    }
})

const OpenLeaderboard = ((data) => {
    LoadLeaderboard(data);
    rankingWrapper.css('display', 'flex');
    setTimeout(() => {
        rankingWrapper.animate({top: '50%'}, 750, 'swing')
    }, 10);
})

document.onkeydown = ((e) => {
    if (e.which == 27) {
        rankingWrapper.animate({top: '350%'}, 750, 'swing');
        setTimeout(() => {
            rankingWrapper.hide();
        }, 700);
        $.post('https://p_halloween/CloseUI');
    }
})

window.addEventListener("message", (event) => {
    const data = event.data;
    switch (data.action) {
        case 'OpenLeaderboard':
            OpenLeaderboard(data.leaderboard);
            break;
    }
})
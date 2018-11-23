<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use App\User;
use App\Thread;
use Illuminate\Auth\AuthenticationException;

class ParticipateInForumTest extends TestCase
{
    use DatabaseMigrations;

    public function testUnauthenticatedUsersMayNotAddReplies()
    {
        $this->expectException(AuthenticationException::class);

        $this->post('threads/0/replies', []);
    }

    public function testAuthenticatedUserMayParticipateInForumThreads()
    {
        $user = factory(User::class)->create();
        $thread = factory(Thread::class)->create();
        $reply = factory(Thread::class)->make();

        $this->be($user);
        $this->post("threads/$thread->id/replies", $reply->toArray());

        $this->get($thread->path())
            ->assertSee($reply->body);
    }
}

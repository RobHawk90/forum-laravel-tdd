<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use App\Thread;
use App\Reply;

class ThreadsTest extends TestCase
{
    use DatabaseMigrations;

    public function setUp()
    {
        parent::setUp();

        $this->thread = factory(Thread::class)->create();
    }

    public function testUserCanViewAllThreads()
    {
        $this->get('/threads')
            ->assertSee($this->thread->title);
    }

    public function testUserCanReadASingleThread()
    {
        $thread = $this->thread;
        $this->get($thread->path())
            ->assertSee($thread->title);
    }

    public function testUserCanReadRepliesThatAreAssociatedWithAThread()
    {
        $thread = $this->thread;
        $reply = factory(Reply::class)
            ->create(['thread_id' => $thread->id]);

        $this->get($thread->path())
            ->assertSee($reply->body);
    }
}
